Function Minimize-Apps
{
    $apps = New-Object -ComObject Shell.Application
    $apps.MinimizeAll()
}