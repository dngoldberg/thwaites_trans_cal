# Clear the output file before writing
> "$output_param_file"


# Read and process each line
      echo "Sliding: $sliding" >> "$output_param_file"
      echo "Timedep: $tdep" >> "$output_param_file"
      echo "MeltType: $melttype" >> "$output_param_file"
      echo "GlenType: $glentype" >> "$output_param_file"
      echo "BetaType: $betatype" >> "$output_param_file"
      echo "Smith: $smithconstr" >> "$output_param_file"
      echo "BigConstr: $bigconstr" >> "$output_param_file"
      echo "gentim: $gentim" >> "$output_param_file"
      echo "proj: $proj" >> "$output_param_file"
      echo "longproj: $longproj" >> "$output_param_file"
      echo "meltconst: $meltconst" >> "$output_param_file"
      echo "tikhbeta: $tikhbeta" >> "$output_param_file"
      echo "tikhbglen: $tikhbglen" >> "$output_param_file"
      echo "bdotdepth: $bdotdepth" >> "$output_param_file"
      echo "wgtvel: $wgtvel" >> "$output_param_file"
      echo "wgtsurf: $wgtsurf" >> "$output_param_file"
      echo "Restart: $reStart" >> "$output_param_file"
      echo "precondMelt: $precondMelt" >> "$output_param_file"
      echo "precondBeta: $precondBeta" >> "$output_param_file"
      echo "precondBglen: $precondBglen" >> "$output_param_file"
      echo "numInvIter: $numInvIter" >> "$output_param_file"
      echo "numInvSaveRun: $numInvSaveRun" >> "$output_param_file"
      echo "expFolder: $expFolder" >> "$output_param_file"

# Print completion message
