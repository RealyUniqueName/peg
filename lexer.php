<?php
$tokens = token_get_all(file_get_contents($argv[1]), TOKEN_PARSE);
$result = [];
$line = 1;
foreach($tokens as $token) {
	if(is_array($token)) {
		$line = $token[2];
		if($token[0] == T_WHITESPACE) {
			$line += substr_count($token[1], "\n");
			continue;
		}
		$token[0] = token_name($token[0]);
	} else {
		switch($token) {
			case "{": case "}": case "(": case ")": case "[": case "]": case "=": case ";": case ",":
				$token = [$token, $token, $line];
				break;
			default:
				continue 2;
		}
	}
	// echo json_encode([$token[0],$token[2]])."\n";
	$result[] = $token;
}
echo json_encode($result);