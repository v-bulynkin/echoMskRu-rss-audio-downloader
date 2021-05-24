function Get-EchoMskRuAudioRss {
    param (
        [parameter(mandatory=$true)]
        $url,
        $depth = 5
    )
    $folder = "$env:USERPROFILE\Music\Podcasts"
    Invoke-WebRequest $url -outfile "$env:TEMP\echoMskRu-rss-audio.xml"
    [xml]$rssA = gc "$env:TEMP\echoMskRu-rss-audio.xml" -encoding utf8
    if (!(Test-Path "$folder")) {mkdir "$folder" > $null}
    $rssA.rss.channel.item |select -First $depth |% {
        $title = $_.title.trim() -replace '\s+',' '
        $mp3 = ($_.guid -as [uri]).Segments[-1]
        $date = ($_.pubdate -as [datetime]).ToLongDateString()
        if (!(Test-Path "$folder\$mp3")) {
            Write-Host -fore Yellow "Скачиваю `"$title`", $date ($mp3)"
            Invoke-WebRequest $_.guid -OutFile "$folder\$mp3"
        }
        else {
            Write-Host -fore Green "`"$title`", $date ($mp3) уже был скачан ранее"
        }
    }
}


$url = Read-host "Введите ссылку на RSS-подкаст сайта Эхо Москвы"
$depth = Read-host "Введите количество скачиваемых аудиофайлов (для стандартного значения 5 просто нажмите клавишу `"Ввод`")"

if ($depth) {
    Get-EchoMskRuAudioRss $url $depth
}
else {
    Get-EchoMskRuAudioRss $url
}
