[xml]$vcxfilters = Get-Content -Path .\SDL_VS2019.vcxproj.filters
$groups = $vcxfilters.Project.ItemGroup
$filters = $groups[0].ChildNodes
$includes = $groups[1].ChildNodes
$compiles = $groups[2].ChildNodes
Write-Output '	<Files>'
$filters | ForEach-Object { 
                $Filter = $_.Include
                $includefiles = ($includes | Where-Object {$_.Filter -and ($_.Filter.ToString() -eq $Filter)})
                $compilefiles = ($compiles | Where-Object {$_.Filter -and ($_.Filter.ToString() -eq $Filter)})
                if ($includefiles -or $compilefiles) {
                    Write-Output '		<Filter'
                    Write-Output ('			Name="'+$Filter+'"')
                    Write-Output '			>'
                    $includefiles | ForEach-Object {
                           Write-Output '			<File'
                           Write-Output ('				RelativePath="'+$_.Include+'"')
                           Write-Output '				>'
                           Write-Output '			</File>'
                           }
                    $compilefiles | ForEach-Object {
                           Write-Output '			<File'
                           Write-Output ('				RelativePath="'+$_.Include+'"')
                           Write-Output '				>'
                           Write-Output '			</File>'
                           }
                    Write-Output '		</Filter>'
                    }
                }
            $includefiles = ($includes | Where-Object {-not $_.Filter})
            $compilefiles = ($compiles | Where-Object {-not $_.Filter})
            if (($includefiles.Count + $compilefiles.Count) -ne 0) {
                $includefiles | ForEach-Object {
                        Write-Output '		<File'
                        Write-Output ('			RelativePath="'+$_.Include+'"')
                        Write-Output '			>'
                        Write-Output '		</File>'
                        }
                $compilefiles | ForEach-Object {
                        Write-Output '		<File'
                        Write-Output ('			RelativePath="'+$_.Include+'"')
                        Write-Output '			>'
                        Write-Output '		</File>'
                        }
                }
Write-Output '	</Files>'
Write-Debug 'done'