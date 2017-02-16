#!/bin/bash

awk '{
		if ($8 == "COMPRADA") {
			printf "%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n", $2, "c", 1, $1, $7, $5, 1, 1, 1
		} else if ($8 == "VENDIDA") {
			printf "%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n", $2, "v", 1, $1, $7, $6, 1, 1, 1
		} else {
			printf "%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n", $2, "c", 1, $1, $3, $5, 1, 1, 1
			printf "%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n", $2, "v", 1, $1, $4, $6, 1, 1, 1
		}
	}' \
	janeiro2017.txt
