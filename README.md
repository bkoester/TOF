# TOF
Various tools for the transcript of the future and liberal arts characterization tools.

## Basic Transcript Tools
`division_credits_intensity.R:` How many credits were taken in different divisions and what was the intensity? <br/>
`disciplinary_depth.R:` Was the course work broad? This creates a subject diversity index? <br/>
`range_of_experience.R:` What were the formats of the courses and how diverse are they? Also, what is the average depth of the course work. <br/>

## Higher Order Tools
`student_course_fixed_effect.R:` How hard was it to get a good grade in a class and how did an individual do compared to peers on average? <br/>
`network_diversity.R:`and connect with a diverse set of peers? <br/>

## Similarities
`compute_pairwise_student_similarities.R:` Based on courses taken, which students are most similar? Which majors? 

This script makes use of the R `coop` library, which speeds up the similarity calculation significantly over something more naive. Roughly speaking, on my Mac laptop this will compute compute similarities for abt 6500 students with 3000 courses on the order of a minute or so. I haven't really studied how it scales. Beware of blowing it up much beyond that due to both time and memory constraints.
