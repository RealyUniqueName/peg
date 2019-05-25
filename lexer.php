<?php

function tokenize($file) {
	$tokens = token_get_all(file_get_contents($file), TOKEN_PARSE);
	// $tokens = token_get_all("<?php \"database={\$database}\";", TOKEN_PARSE);
	$result = [];
	$line = 1;
	foreach($tokens as $token) {
		if(is_array($token)) {
			$line = $token[2];
			if($token[0] == T_WHITESPACE || $token[0] == T_COMMENT) {
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
	$json = json_encode($result);
	if(json_last_error() !== JSON_ERROR_NONE) {
		throw new \Exception(json_last_error_msg());
	}
	return $json;
}

//if executed as a standalone script
if(!class_exists('php\Boot')) {
	echo tokenize($argv[1]);
}