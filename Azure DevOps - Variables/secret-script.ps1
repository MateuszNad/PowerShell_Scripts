param(
    $Secret
)

Write-Output $Secret
for ($i = 0; $i -lt $Secret.Length; $i++)
{
    [array]$AsPlain += $Secret[$i]
}
Write-Output ($AsPlain -join ' ')
