# EF-assessment

In the previous work: , we proposed the effect size, especially Cohen's d, as a feature selection method. The taraget of the work is to use this novel method to select 
the best relevant features to diagnose breast cancer. Since Cohen's d is useful to measure the association significance of two normal distributions, the main
idea is to measure the variable importance by measuring the association between the variable distribution for the benign sample (Class B) and the malignant sample (Class M). 

## Breast cancer

Breast cancer is the most deadly cancer in the world that affects the milk-conducts. According to the World Health Organization in 2022, breast cancer was diagnosed to over 
2.3 million women and 670,000 deaths globally. Breast cancer is classified in phases according to the spread in the body. Thus, the first phase starts cancer with a 
cancerous cell, and grows until the fifth phase, spreading the cancer to other body parts. Additionally, the possibility of death increases too much when the cancer grows.  
  
### Dataset

For both ... and this work it ptoposed the well know dataset wich is based on measure certain characteristics, such as symmetry, concaveity, area, perimeter, radius, etc. of the nuclear cell presents in a FNA (Fine Needle Aspiration) sample. Then, the mean, standard deviations and large value it is computed for each sample. FNA is a non-invaisve techineqe of byiopsia used to study breast cancer. 

## Effect size

Since Cohen' d assume homogeneous variances and normak distributions, the porposed objetive in this work and the future worj is evaluate parametrics and non-parametrics effect sizes. The actual work is based on the following parametrics effect size:

1. Cohen's d: measure the associating power of two normla distriburions.
2. Cohen's D: it is equal to Cohen' d, but not assume homogeneous variances, so it is based in a Welch's t-test
3. Cohen's U1:
4. Cohen's U2
5. Cohen's U3

Then the results were compared with Relief and were assessed the different feature selection methods with an SVM classification model.

## Organization
The work is organized as follows:
