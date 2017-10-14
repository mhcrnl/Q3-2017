		CHESS OPENINGS: Simple tool to practise chess openings.

SYNOPSIS

        chess-openings.pl [ -h|--help ] [ -c|--conf configuration_file_containing_list_of_openings ]

DESCRIPTION
       CHESS OPENINGS is a simple perl script to practise chess openings. It
       is provided with a default configuration file containing a list of 437
       well known openings. CHESS OPENINGS chooses randomly one opening in the
       configuration file and displays it as a nice UTF-8 matrix (UTF-8 do
       support chess characters). CHESS OPENINGS may be simply used through
       the command line but may be also be called by other tools like screen
       savers. A little review with a screenshot is available here :
       http://kwartik.wordpress.com/chess-openings.

PARAMETERS
       All the parameters can be preconfigured in the configurable section at
       the beginning of the script. The parameters that are passed through the
       command line override the parameters set in the configurable section.

        -h|--help print help

        -c|--conf configuration_file_containing_the_list_of_openings

LIMITATIONS
       This script is intended to be used in a UTF-8 environment supporting
       the chess characters. It has been successfully tested in a Linux
       terminal. Unfortunately, under Windows, the "terminal" (cmd.exe) is not
       able to print UTF-8 characters, so Windows users might need to use a
       two steps approach : 1. redirection of the output in a file: perl
       chess-openings > opening.out 2. edition of the output file with a UTF-8
       compliant editor providing a nice font for chess characters.

CONFIGURATION FILE SYNTAX
        Each opening must be saved on one single line with the following
        convention : list of moves|name of the opening

        Eg. : 1.d4 d5 2.c4 c6 3.Nf3 Nf6 4.Nc3 dxc4 5.a4 Bf5 6.Ne5 Nbd7 7.Nxc4
        Qc7 8.g3 e5|Carlsbad Variation of the Slav Defense

        Please note that only the chess international notation is supported
        (without the annotations characters ? and !). The notation 1. e2e4
        e4e6 is not supported.

AUTHOR
       kwartik@gmail.com

LICENCE
           Copyright 2010 kwartik@gmail.com

           Licensed under the Apache License, Version 2.0 (the "License");
           you may not use this file except in compliance with the License.
           You may obtain a copy of the License at

             http://www.apache.org/licenses/LICENSE-2.0

           Unless required by applicable law or agreed to in writing, software
           distributed under the License is distributed on an "AS IS" BASIS,
           WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
           See the License for the specific language governing permissions and
           limitations under the License.




