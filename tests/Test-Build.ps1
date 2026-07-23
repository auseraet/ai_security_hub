[CmdletBinding()]
param()

Set-StrictMode -Version 2.0
$ErrorActionPreference = "Stop"

$RepoRoot = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot ".."))
$BuildScript = Join-Path $RepoRoot "scripts/build.ps1"
$Engine = if (Get-Command pwsh -ErrorAction SilentlyContinue) { (Get-Command pwsh).Source } else { (Get-Command powershell.exe).Source }
$TestRoot = Join-Path ([IO.Path]::GetTempPath()) ("skills-hub-tests-" + [Guid]::NewGuid().ToString("N"))
$Utf8NoBom = New-Object Text.UTF8Encoding($false)
$Passed = 0
$Failed = 0
[IO.Directory]::CreateDirectory($TestRoot) | Out-Null

function Write-TestFile([string]$Path, [string]$Content) {
    [IO.Directory]::CreateDirectory((Split-Path -Parent $Path)) | Out-Null
    [IO.File]::WriteAllText($Path, $Content, $Utf8NoBom)
}

function Invoke-Build([string[]]$BuildArguments) {
    $allArguments = @("-NoProfile", "-ExecutionPolicy", "Bypass", "-File", $BuildScript) + $BuildArguments
    $previousPreference = $ErrorActionPreference
    try {
        $ErrorActionPreference = "Continue"
        & $Engine @allArguments *> $null
        return $LASTEXITCODE
    } finally {
        $ErrorActionPreference = $previousPreference
    }
}

function Assert-True([bool]$Condition, [string]$Message) {
    if (-not $Condition) { throw $Message }
}

function Read-State([string]$Target) {
    return ConvertFrom-Json ([IO.File]::ReadAllText((Join-Path $Target ".github/.skills-hub.json")))
}

function Run-Test([string]$Name, [scriptblock]$Body) {
    try {
        & $Body
        Write-Output "PASS $Name"
        $script:Passed += 1
    } catch {
        Write-Error "FAIL ${Name}: $($_.Exception.Message)"
        $script:Failed += 1
    }
}

try {
    Run-Test "default policy is full and path-specific" {
        $target = Join-Path $TestRoot "default-policy"
        [IO.Directory]::CreateDirectory($target) | Out-Null
        Assert-True ((Invoke-Build @("-Target", $target)) -eq 0) "build failed"
        $state = Read-State $target
        $catalog = ConvertFrom-Json ([IO.File]::ReadAllText((Join-Path $RepoRoot "catalog/catalog.json")))
        Assert-True ($state.preset -eq "full") "default preset is not full"
        Assert-True ($state.mode -eq "path-specific") "default mode is not path-specific"
        Assert-True (@($state.modules).Count -eq @($catalog.modules).Count) "default build did not select every catalog module"
        foreach ($id in @("java-kotlin", "spring", "csharp-dotnet", "c-cpp", "wordpress-drupal")) {
            Assert-True (Test-Path -LiteralPath (Join-Path $target ".github/instructions/$id.instructions.md")) "missing default instruction $id"
        }
    }

    Run-Test "stack detection" {
        $target = Join-Path $TestRoot "detection"
        Write-TestFile (Join-Path $target "src/app.tsx") "export default function App() {}`n"
        Write-TestFile (Join-Path $target "package.json") '{"dependencies":{"react":"1","express":"1"}}'
        Write-TestFile (Join-Path $target "Dockerfile") "FROM scratch`n"
        Assert-True ((Invoke-Build @("-Target", $target, "-Preset", "baseline")) -eq 0) "build failed"
        $state = Read-State $target
        foreach ($id in @("javascript-typescript", "next-react", "express-nest", "containers")) {
            Assert-True (@($state.modules) -contains $id) "missing detected module $id"
        }
    }

    Run-Test "cross-technology detection" {
        $target = Join-Path $TestRoot "cross-technology-detection"
        Write-TestFile (Join-Path $target "src/main/java/com/company/AccountController.java") "package com.company; public class AccountController {}`n"
        Write-TestFile (Join-Path $target "pom.xml") '<project><dependencies><dependency><artifactId>spring-boot-starter-web</artifactId></dependency></dependencies></project>'
        Write-TestFile (Join-Path $target "src/dotnet/ApiController.cs") "public sealed class ApiController {}`n"
        Write-TestFile (Join-Path $target "src/dotnet/Api.csproj") '<Project Sdk="Microsoft.NET.Sdk.Web"></Project>'
        Write-TestFile (Join-Path $target "native/main.cpp") "int main() { return 0; }`n"
        Write-TestFile (Join-Path $target "cms/wp-config.php") '<?php define("WP_DEBUG", false);'
        Write-TestFile (Join-Path $target "cms/wp-content/plugins/example/example.php") '<?php'
        Write-TestFile (Join-Path $target "cms/modules/custom/example/example.module") '<?php'
        Assert-True ((Invoke-Build @("-Target", $target, "-Preset", "baseline")) -eq 0) "build failed"
        $state = Read-State $target
        foreach ($id in @("java-kotlin", "spring", "csharp-dotnet", "aspnet-core", "c-cpp", "php", "wordpress-drupal")) {
            Assert-True (@($state.modules) -contains $id) "missing detected module $id"
            Assert-True (Test-Path -LiteralPath (Join-Path $target ".github/instructions/$id.instructions.md")) "missing generated instruction $id"
        }
    }

    Run-Test "path-specific output and review pack" {
        $target = Join-Path $TestRoot "path-specific"
        Write-TestFile (Join-Path $target "main.py") "print('ok')`n"
        Assert-True ((Invoke-Build @("-Target", $target)) -eq 0) "build failed"
        Assert-True (Test-Path -LiteralPath (Join-Path $target ".github/instructions/python.instructions.md")) "Python instruction missing"
        Assert-True (Test-Path -LiteralPath (Join-Path $target ".github/agents/secure-code-review.agent.md")) "review agent missing"
        Assert-True (Test-Path -LiteralPath (Join-Path $target ".github/prompts/secure-code-review.prompt.md")) "review prompt missing"
        Assert-True (Test-Path -LiteralPath (Join-Path $target ".github/skills/secure-code-review-method/SKILL.md")) "review skill missing"
        Assert-True ((Read-State $target).reviewPack -eq $true) "review pack state missing"
    }

    Run-Test "universal mode" {
        $target = Join-Path $TestRoot "universal"
        Write-TestFile (Join-Path $target "main.py") "print('ok')`n"
        Assert-True ((Invoke-Build @("-Target", $target, "-Mode", "universal")) -eq 0) "build failed"
        $core = [IO.File]::ReadAllText((Join-Path $target ".github/copilot-instructions.md"))
        Assert-True ($core.Contains("# Python secure coding")) "detected Python guidance missing"
        Assert-True (-not $core.Contains("applyTo:")) "frontmatter leaked into universal output"
        Assert-True (-not (Test-Path -LiteralPath (Join-Path $target ".github/instructions"))) "path instructions should not exist"
    }

    Run-Test "protect non-generated instructions" {
        $target = Join-Path $TestRoot "protect"
        $instruction = Join-Path $target ".github/copilot-instructions.md"
        Write-TestFile $instruction "my local rules`n"
        Assert-True ((Invoke-Build @("-Target", $target)) -eq 2) "build should refuse overwrite"
        Assert-True (([IO.File]::ReadAllText($instruction)) -eq "my local rules`n") "user instruction changed"
    }

    Run-Test "local instructions" {
        $target = Join-Path $TestRoot "local"
        Write-TestFile (Join-Path $target ".github/skills-hub-local.md") "Use the project's verify command.`n"
        Assert-True ((Invoke-Build @("-Target", $target)) -eq 0) "build failed"
        $core = [IO.File]::ReadAllText((Join-Path $target ".github/copilot-instructions.md"))
        Assert-True ($core.Contains("verify command")) "local instructions not appended"
        Assert-True (-not (@((Read-State $target).managedFiles) -contains ".github/skills-hub-local.md")) "local file became managed"
    }

    Run-Test "drift check" {
        $target = Join-Path $TestRoot "drift"
        Write-TestFile (Join-Path $target "main.go") "package main`n"
        Assert-True ((Invoke-Build @("-Target", $target, "-Check")) -eq 1) "empty target should drift"
        Assert-True ((Invoke-Build @("-Target", $target)) -eq 0) "generation failed"
        Assert-True ((Invoke-Build @("-Target", $target, "-Check")) -eq 0) "generated target should be current"
    }

    Run-Test "mode change removes stale instructions" {
        $target = Join-Path $TestRoot "mode-change"
        Write-TestFile (Join-Path $target "main.py") "print('ok')`n"
        Assert-True ((Invoke-Build @("-Target", $target)) -eq 0) "path-specific build failed"
        $pythonInstruction = Join-Path $target ".github/instructions/python.instructions.md"
        Assert-True (Test-Path -LiteralPath $pythonInstruction) "Python instruction missing"
        Assert-True ((Invoke-Build @("-Target", $target, "-Mode", "universal")) -eq 0) "universal build failed"
        Assert-True (-not (Test-Path -LiteralPath $pythonInstruction)) "stale Python instruction remains"
    }

    Run-Test "selection controls" {
        $target = Join-Path $TestRoot "selection-controls"
        Write-TestFile (Join-Path $target "main.py") "print('ok')`n"
        Assert-True ((Invoke-Build @("-Target", $target, "-Preset", "baseline", "-NoDetect", "-Include", "ai-ml", "-Exclude", "browser-web")) -eq 0) "build failed"
        $state = Read-State $target
        Assert-True (@($state.modules) -contains "core") "core missing"
        Assert-True (@($state.modules) -contains "ai-ml") "explicit include missing"
        Assert-True (-not (@($state.modules) -contains "browser-web")) "excluded module remains"
        Assert-True (-not (@($state.modules) -contains "python")) "detection was not disabled"
    }
} finally {
    if (Test-Path -LiteralPath $TestRoot) { Remove-Item -LiteralPath $TestRoot -Recurse -Force }
}

Write-Output "$Passed passed; $Failed failed."
if ($Failed -gt 0) { exit 1 }
exit 0
