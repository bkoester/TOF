# TOF
Various tools for the transcript of the future and liberal arts characterization tools.

## Basic Transcript Tools
How many credits were taken in different divisions and what was the intensity? Was the course work deep or broad, and what were the formats of the courses?

## Higher Order Tools
How hard was it to get a good grade in a class, and how did an individual do compared to peers on average? Did the student sample a high diversity of subjects and connect with a diverse set of peers?

## Similarities
The `compute_pairwise_student_similarities.R:` This script makes use of the R `coop` library, which speeds up the similarity calculation significantly over something more naive. Roughly speaking, on my Mac laptop this will compute compute similarities for abt 6500 students with 3000 courses on the order of a minute or so. I haven't really studied how it scales. Beware of blowing it up much beyond that due to both time and memory constraints.
