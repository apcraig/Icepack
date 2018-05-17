#!/bin/csh -f
if (`where curl` == "") then
  (>&2 echo "ERROR: Code coverage reporting (--codecov) needs 'curl' to upload results")
  exit(1)
endif

# token from https://codecov.io/gh/CICE-Consortium/Icepack/settings
setenv CODECOV_TOKEN "df12b574-8dce-439d-8d3b-ed7428d7598a"

# The test-coverage files (*.gcno,*.gcda) must reside next to the source code
# for the coverage reporting to work. However, the coverage files are created
# for each test. For that reason, this script will copy the coverage files over
# to the source directory and report the results, one test at a time. Codecov.io
# is clever enough to report the cumulative results.
echo "Looping over test cases and uploading test coverage"
set testdirs=`ls -d ${ICE_MACHINE_WKDIR}/*`
foreach dir ($testdirs)
  echo "## Submitting results from ${dir}"
  cp $dir/compile/*.{gcno,gcda} ${ICE_SANDBOX}/columnphysics/
  if ( $status == 0 ) then
      echo "Uploading coverage results to codecov.io"
      bash -c "bash <(curl -s https://codecov.io/bash)"
  else
      echo "No coverage files found for this test"
  endif
end
