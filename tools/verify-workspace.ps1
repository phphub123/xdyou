param(
    [Parameter(Mandatory = $false)]
    [string]$TargetRoot = "."
)

$ErrorActionPreference = "Stop"
$TargetRoot = (Resolve-Path $TargetRoot).Path
$SkillRoot = Join-Path $TargetRoot ".agents\skills"
$RagScript = Join-Path $SkillRoot "cangjie-harmonyos-knowledge\rag\cjdocs.py"
$Index = Join-Path $SkillRoot "cangjie-harmonyos-knowledge\rag\.cjdocs\index.sqlite"
$Config = Join-Path $TargetRoot "cjdocs.toml"
$EvidenceDir = Join-Path $TargetRoot "evidence"
$EvidenceFile = Join-Path $EvidenceDir "knowledge-gate.txt"

$RequiredFiles = @(
    "AGENTS.md",
    "cjdocs.toml",
    "build-profile.json5",
    "entry\cjpm.toml",
    "entry\src\main\module.json5",
    "source\pubspec.yaml",
    "source\lib\main.dart",
    "acceptance\acceptance-matrix.csv"
)

$RequiredSkills = @(
    "harmonyos-cangjie-dev",
    "harmonyos-project-bootstrap",
    "cangjie-core-reference",
    "cangjie-harmonyos-knowledge",
    "harmonyos-build-run-diagnose",
    "harmonyos-evolution",
    "cangjie-arkts-interop"
)

foreach ($RelativePath in $RequiredFiles) {
    $Path = Join-Path $TargetRoot $RelativePath
    if (-not (Test-Path $Path)) {
        throw "工作区缺少文件：$Path"
    }
}

foreach ($Skill in $RequiredSkills) {
    $Path = Join-Path $SkillRoot "$Skill\SKILL.md"
    if (-not (Test-Path $Path)) {
        throw "缺少 skill：$Path"
    }
}

$Essentials = Join-Path $SkillRoot "cangjie-essentials.md"
if (-not (Test-Path $Essentials)) {
    throw "缺少仓颉基础规则：$Essentials"
}
if (-not (Test-Path $RagScript)) {
    throw "缺少 cjdocs.py：$RagScript"
}
if (-not (Test-Path $Index)) {
    throw "缺少本地 RAG 索引：$Index"
}
if ((Get-Item $Index).Length -lt 1MB) {
    throw "本地 RAG 索引异常小：$Index"
}

$Cjpm = Get-Content -Raw (Join-Path $TargetRoot "entry\cjpm.toml")
if ($Cjpm -notmatch "\[target\.x86_64-linux-ohos\]") {
    throw "entry\cjpm.toml 缺少 x86_64 模拟器目标"
}
if ($Cjpm -notmatch "\[target\.aarch64-linux-ohos\]") {
    throw "entry\cjpm.toml 缺少 aarch64 真机目标"
}

$BuildProfile = Get-Content -Raw (Join-Path $TargetRoot "build-profile.json5")
if ($BuildProfile -notmatch '"compatibleSdkVersion"\s*:\s*"6\.1\.0\(23\)"') {
    throw "Compatible SDK 不是 6.1.0(23)"
}

$DartFiles = Get-ChildItem -Path (Join-Path $TargetRoot "source\lib") -Recurse -Filter *.dart
if ($DartFiles.Count -lt 250) {
    throw "Flutter 最小源集不完整，仅发现 $($DartFiles.Count) 个 Dart 文件"
}

New-Item -ItemType Directory -Force -Path $EvidenceDir | Out-Null
Push-Location $TargetRoot
try {
    "=== workspace ===" | Set-Content -Encoding UTF8 $EvidenceFile
    "root=$TargetRoot" | Add-Content -Encoding UTF8 $EvidenceFile
    "dart_files=$($DartFiles.Count)" | Add-Content -Encoding UTF8 $EvidenceFile
    "index_bytes=$((Get-Item $Index).Length)" | Add-Content -Encoding UTF8 $EvidenceFile
    "=== doctor ===" | Add-Content -Encoding UTF8 $EvidenceFile
    python $RagScript --config $Config doctor 2>&1 |
        Tee-Object -FilePath $EvidenceFile -Append
    $DoctorExitCode = $LASTEXITCODE
    "=== first offline query ===" | Add-Content -Encoding UTF8 $EvidenceFile
    python $RagScript --config $Config query "ArkUI Button TextInput state onClick" --top-k 8 2>&1 |
        Tee-Object -FilePath $EvidenceFile -Append
    $QueryExitCode = $LASTEXITCODE
} finally {
    Pop-Location
}

if ($DoctorExitCode -ne 0 -or $QueryExitCode -ne 0) {
    throw "知识库验证失败，请查看：$EvidenceFile"
}

Write-Host "工作区、skills、离线知识库、SDK 与双架构检查通过。"
Write-Host "证据：$EvidenceFile"
