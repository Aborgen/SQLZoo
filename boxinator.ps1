# Sloppy script to ornament data that is copied from an HTML <table>.
# It doesn't currently line up columns.
<#
Example:
+----------------------------+
| Field | Type | Null 
+----------------------------+
| id | int(11) | NO | 
| Name | varchar(50) | YES |
| Contact_id | int(11) | YES |
+----------------------------+
#>

function printBorder($lineLength, $postList, $offset) {
  $border = '+';
  $groovy = $lineLength + ($offset * 2);
  for ($i = 0; $i -lt $groovy; $i++) {
    foreach ($postIdx in $postList) {
	  if ($i -eq $postIdx) {
	    $border += '+';
		if ($postList.Count > 1) {
		  $postList.RemoveAt($i);
		}

		continue;
	  }
	}
	
	$border += '-';
  }
  
  $border += '+';
  return $border;
}

$foo =
Get-Clipboard;

$foo = $foo.Split("`n");
$rows = [System.Collections.ArrayList]::new();
for ($i = 0; $i -lt $foo.Count; $i++) {
  $rows.Add($foo[$i].Split("`t")) | Out-Null;
}

$lineLength = 0;
$longestIndex = 0;
for ($i = 0; $i -lt $rows.Count; $i++) {
  if ($foo[$i].Length -gt $lineLength) {
    $lineLength = $foo[$i].Length;
	$longestIndex = $i;
  }
}

$posts = [System.Collections.ArrayList]::new();
$border = printBorder $lineLength $posts $rows[0].Count;


$box = "$border`n";
for ($i = 0; $i -lt $rows.Count; $i++) {
  foreach ($word in $rows[$i]) {
    $box += "| $word ";
  }
  
  $box += "|`n";
  if ($i -eq 0) {
    $box += "$border`n";
  }
  elseif ($i -eq $rows.Count - 1) {
    $box += "$border";
  }
}

Set-Clipboard $box;
Write-Host $box;
