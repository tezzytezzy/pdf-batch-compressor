# PDF Batch Compressor

## Functionality
This nifty utility compresses PDF files via [Ghostscript](https://www.ghostscript.com/) in the folder where this script resides:  
:one: Create a sub-folder, ./compressed, and put the resultant compressed ones in it,  
:two: Compress files with any PDF extentions i.e., .pdf, .PDF, .pDf and so on,  
:three: Optional compression parameter to be supplied, namely, prepress, ebook (default) and screen - in the descending order of quality, and  
:four: Log output with the compressed file names and any error message in the sub-folder  
N.B. Make sure to make this script excutable via `chmod +x` or `755`, after downloading!

## Installation
```bash
(base) to@mx:~$ bash --version
GNU bash, version 4.4.12(1)-release (x86_64-pc-linux-gnu)
(base) to@mx:~$ gs --help
GPL Ghostscript 9.26 (2018-11-20)
```
