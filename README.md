# 📦 PDF Batch Processor

![GitHub Release](https://img.shields.io/github/v/release/tezzytezzy/pdf-batch-compressor)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)


A Bash utility to optimize, monochrome-ify, and strip content from PDFs in bulk.

---

## 📖 Table of Contents

1. [Features](#-features)  
2. [Installation](#-installation)  
3. [Usage](#-usage)  
4. [Configuration](#-configuration)  
5. [Log](#-log)  
6. [Tested Environment](#-tested-environment)
7. [Sample Compression](#-sample-compression)
8. [References](#-references)
---

## 🌟 Features

- **Compression**: Choose from presets (`screen`, `ebook`, `printer`, `prepress`, or `default`)  
- **Monochrome Conversion**: Transform color PDFs to B/W  
- **Selective Stripping**: Drop images, text, and vectors as needed  
---

## 🔧 Installation

```bash
# Clone repo
git clone https://github.com/tezzytezzy/pdf-batch-processor.git
cd pdf-batch-processor/

# Make executable
chmod +x pdf-batch-processor.sh
```

---

## 🚀 Usage

```bash
./pdf-batch-processor.sh
```

- Processes every `.pdf` in the current directory  
- Outputs into `compressed_files/`  
- Generates `compression_report.log`  

---

## 🛠 Configuration

```bash
hp@HP:~$ ./pdf_batch_compressor.sh -h
Usage: pdf_batch_compressor.sh [OPTIONS]

Compresses all .pdf files in the script’s directory into
a fresh ./compressed_files/ folder and emits a log.

Options:
  -p, --preset PRE         PDFSETTINGS preset. One of:
                           screen, ebook, printer, prepress, default
  -c, --color COL          Color strategy: Gray or LeaveColorUnchanged
      --gray               Shortcut for --color=Gray
  -i, --filter-image       Add -dFILTERIMAGE
  -t, --filter-text        Add -dFILTERTEXT
  -v, --filter-vector      Add -dFILTERVECTOR
  -h, --help               Show this help and exit

Examples:
  # screen preset + gray + image filter
  ./pdf_batch_compressor.sh --preset=screen --gray --filter-image

  # ebook preset, keep colors, text+vector filters
  ./pdf_batch_compressor.sh -p ebook -i -v

  # default preset + LeaveColorUnchanged
  ./pdf_batch_compressor.sh

  # "--gray" takes precedent over "-c LeaveColorUnchanged" where both are supplied
  (The following three are equivalent)
  ./pdf_batch_compressor.sh -c LeaveColorUnchanged --gray
  ./pdf_batch_compressor.sh -c Gray
  ./pdf_batch_compressor.sh --gray
```

---

## 📈 Log
```text
Compression Report – Sun Jun 29 10:40:50 AM PDT 2025

Filename           Original(bytes)   Compressed(bytes)   Ratio(%)
MyFile.pdf         167997            24773               14.75
```

---

## 📄 Tested Environment
```bash
hp@HP:~$ bash --version
GNU bash, version 5.2.21(1)-release (x86_64-pc-linux-gnu)
Copyright (C) 2022 Free Software Foundation, Inc.
License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>

This is free software; you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.
hp@HP:~$ gs --version
10.02.1
```

---

## 📊 Sample Compression  
| PDF File               | File Size | Ratio (%) |
| -----------------------| --------  | ----------|    
| Original*              | 218.4 kB  | --        |
| screen preset only     | 30.2 kB   | 13.82     |
| screen preset and gray | 24.8 kB   | 11.36     |

*This is a one-page PDF containing four equally-sized, full-color portrait images and no text.

---

## 📚 References
- [Optimizing PDFs with Ghostscript](https://ghostscript.com/blog/optimizing-pdfs.html)
- [Switches for PDF Files](https://ghostscript.readthedocs.io/en/latest/Use.html#switches-for-pdf-files)
- [The family of PDF and PostScript output devices](https://ghostscript.readthedocs.io/en/latest/VectorDevices.html#the-family-of-pdf-and-postscript-output-devices)


