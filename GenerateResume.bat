@echo off
rem Install Pandoc and set JOBSEARCH_DIR environment variable before running this script.
pandoc --reference-doc "%JOBSEARCH_DIR%\Resume\Resumetemplate.docx" -o "%~n1.docx" %1