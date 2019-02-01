# TOF
Various tools for the transcript of the future and liberal arts characterization tools.

## Similarities
The `compute_pairwise_student_similarities.R:` This script makes use of the R `coop` library, which speeds up the similarity calculation significantly over something more naive. Roughly speaking, on my Mac laptop this will compute compute similarities for abt 6500 students with 3000 courses on the order of a minute or so. I haven't really studied how it scales. Beware of blowing it up much beyond that due to both time and memory constraints.
