# TOF
Various tools for the transcript of the future and liberal arts characterization tools.

## Inputs
These scripts one or sometimes two tables as inputs. We refer to one as the *student_course* table, and the other the *student record*. The tables are assumed to be cleaned, with the sample of students and courses already defined.

`student_course` (sc): This contains all student-courses, one line per student-course, as each student may take multiple courses. The courses that should be included are set but what is contained in this table. It must contain at least the following:
* STDNT_ID: A unique integer student identifier
* TERM_CD: A term-specific, ordered integer code that indicates the term a course was offered.
* CRSE_CIP_CD_DES: course CIP CD if available. if not, set it equal to the SBJCT_CD.
* SBJCT_CD: Course subject code (character)
* CATLG_NBR: Course catalog number. This is assumed to be an integer for the purposes of the depth calculation, it clearly is not this way at every institution.
* CLASS_NBR: A unique number for each instance of a course. This is most useful for courses with multiple sections within a term where the grading practices vary among sections.
* CLASS_SCTN_CD: the section number of a course within a term. This section number may be the same over many terms of the course. 
* UNITS_ERND_NBR: the number credits given for completion of the course.
* GRD_PNTS_PER_UNIT_NBR: floating number of grade points corresponding to a course grade. 

`student_record` (sr): This contains one-time information for students. Currently, not much is required, but this is the table where the student sample should be pre-defined by the user.
* STDNT_ID: A unique integer student identifier. This ID should be consistent with that used in the student course table.
* UM_DGR_1_MAJOR_1_DES: the student's graduating major. It currently acknowledge only a single major (no double majors).

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
