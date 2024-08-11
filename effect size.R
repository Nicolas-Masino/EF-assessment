library(effsize)
library(effectsize)
library(lsr)
library(ggplot2)
library(dplyr)
library(MBESS)

#re order benign data and malignant data
new_order = c(2:31, 1)
benignData <- benignData[, new_order]
malignantData <- malignantData[, new_order]


EffectSize <- function(x, y, technique, ci){
  if(technique == 'unequal'){
    effect_size <- cohensD(x, y, method = 'unequal')
  }
 
  # is the proportion of the total of both distributions that does not overlap
  if(technique == 'cohen_u1'){ 
    result <- cohens_u1(x, y)
    effect_size <- result$Cohens_U1
    ci_low = result$CI_low
    ci_high = result$CI_high
  }
  
  #is the proportion of one of the groups that exceeds the same proportion in the other group.
  if(technique == 'cohen_u2'){
    result <- cohens_u2(x, y, parametric = TRUE)
    effect_size <- result$Cohens_U2
    ci_low = result$CI_low
    ci_high = result$CI_high
  }
  
  #is the proportion of the second group that is smaller than the median of the first group.
  if(technique == 'cohen_u3'){
    result <- cohens_u3(x, y, parametric = TRUE)
    effect_size <- result$Cohens_U3
    ci_low = result$CI_low
    ci_high = result$CI_high
  }
  
  #Probability of superiority
  if(technique == 'superiority'){
    result <- p_superiority(x, y)
    effect_size <- result$p_superiority
    ci_low = result$CI_low
    ci_high = result$CI_high
  }
  if(technique == 'overlap'){
    result <- p_overlap(x, y, parametric = FALSE)
    effect_size <- result$Overlap
    ci_low = result$CI_low
    ci_high = result$CI_high
  }
  
  # Vargha and Delaney A
  if(technique == 'vd_a'){
    result <- vd_a(x, y)
    effect_size <- result$p_superiority
    ci_low = result$CI_low
    ci_high = result$CI_high
  }
  
  # Wilcoxon-Mann-Whitney odds ratio
  if(technique == 'wmw_ratio'){
    result <- wmw_odds(x, y)
    effect_size <- result$WMW_odds
    ci_low = result$CI_low
    ci_high = result$CI_high
  }
  if(ci){
    return(c(ci_low, ci_high))
  }
  else{
  return(c(effect_size))
  }
}

EffectSize_df <- data.frame('variable' = colnames(df[2:31]))
CiEffectSize <- data.frame('variable' = colnames(df[2:31]))

Estimate_EffectSize <- function(tec, ci = FALSE){
  result <- lapply(1:30, function(i){
    y = benignData[, i]
    x = malignantData [, i]
    res <- EffectSize(x, y, technique = tec, ci = ci)
    return(res)
  })
  return(result)
}


EffectSize_df$unequal <- Estimate_EffectSize(tec = 'unequal')
EffectSize_df$cohen_u1 <- Estimate_EffectSize(tec = 'cohen_u1')
EffectSize_df$cohen_u2 <- Estimate_EffectSize(tec = 'cohen_u2')
EffectSize_df$cohen_u3 <- Estimate_EffectSize(tec = 'cohen_u3')
EffectSize_df$p_superiority <- Estimate_EffectSize(tec = 'superiority')
EffectSize_df$p_overlap <- Estimate_EffectSize(tec = 'overlap')
EffectSize_df$vd_a <- Estimate_EffectSize(tec = 'vd_a')
EffectSize_df$wmw_ratio <- Estimate_EffectSize(tec = 'wmw_ratio')

CiEffectSize$cohen_u1 <- Estimate_EffectSize(tec = 'cohen_u1', ci = TRUE)
CiEffectSize$cohen_u2 <- Estimate_EffectSize(tec = 'cohen_u2', ci = TRUE)
CiEffectSize$cohen_u3 <- Estimate_EffectSize(tec = 'cohen_u3', ci = TRUE)
CiEffectSize$superiority <- Estimate_EffectSize(tec = 'superiority', ci = TRUE)
CiEffectSize$overlap <- Estimate_EffectSize(tec = 'overlap', ci = TRUE)
CiEffectSize$vd_a <- Estimate_EffectSize(tec = 'vd_a', ci = TRUE)
CiEffectSize$wmw_ratio <- Estimate_EffectSize(tec = 'wmw_ratio', ci = TRUE)

estimate_ci <- function(d){
 CIs <- ci.smd(smd = d, n.1 = 212, n.2 = 357)
 ci_lower = CIs$Lower.Conf.Limit.smd
 ci_high = CIs$Upper.Conf.Limit.smd
 return(c(ci_lower, ci_high))
}


ncp <- smd * sqrt((n.1 * n.2)/(n.1 + n.2))
alpha.lower <- (1 - conf.level)/2
alpha.upper <- (1 - conf.level)/2

collectors <- function(D){
  result <- lapply(D, function(i){
    res <- estimate_ci(i)
    return(res)
  })
  return(result)
}

CiEffectSize$unequal <- collectors(EffectSize_df$unequal)
CiEffectSize$cohen_d <- collectors(cohenVar$cohen.d)

x <- ci.smd(smd = 0.843834610613014, n.1 = 212, n.2 = 357)
x <- vd_a(benignData$radius_mean, malignantData$radius_mean)

d <- mean(x) - mean(y)
s1 <- stats::sd(x)
s2 <- stats::sd(y)
n1 <- length(x)
n2 <- length(y)
n <- n1 + n2

s <- suppressWarnings(sd_pooled(malignantData$radius_mean, benignData$radius_mean))
hn <- (1/n1 + 1/n2)
se <- s * sqrt(1/n1 + 1/n2)
df <- n - 2
out <- data.frame(d = (d - mu)/s)

hn <- (1/n1 + 1/n2)
t <- (d - mu)/se
ts <- .get_ncp_t(t, df, ci.level)

function (t, df_error, conf.level = 0.95) 
{
  #df_error = 567
  #t = 26.40521
  alpha <- 1 - conf.level
  probs <- c(alpha/2, 1 - alpha/2)
  ncp <- suppressWarnings(stats::optim(par = 1.1 * rep(t, 2), 
                                       fn = function(x) {
                                         q <- stats::qt(p = probs, 
                                                        df = df_error, 
                                                        ncp = x)
                                         sum(abs(q - t))}, 
                                       control = list(abstol = 1e-09)))
  t_ncp <- unname(sort(ncp$par))
  return(t_ncp)
}
out$CI_low <- ts[1] * sqrt(hn)
out$CI_high <- ts[2] * sqrt(hn)

d = mean(malignantData$perimeter_mean)-mean(benignData$perimeter_mean)
# d = 37.2899
alpha = 0.05
probs = c(alpha/2, 1 - alpha/2)
s<-sd_pooled(malignantData$perimeter_mean, benignData$perimeter_mean)
#s = 16.2872
#se = 1.41222
se <- s*sqrt(1/212 + 1/357)
t <- d/se

fn <- function(x){
  q <- stats::qt(p = probs,
                 df = 567,
                 ncp = x)
  sum(abs(q - t))
}


stats::optim(par = 1.1 * rep(t, 2), 
             fn = function(x) {
               q <- stats::qt(p = probs,
                              df = 567,
                              ncp = x)
               sum(abs(q - t))}, 
             control = list(abstol = 1e-09))

Optimization <- function(){
  optim(par = 1.1 * rep(t, 2), 
      fn = function(x) {
        q <- stats::qt(p = probs,
                       df = 567,
                       ncp = x)
        sum(abs(q - t))}, 
      control = list(abstol = 1e-09))
}

Quantile <- function(x){
  qt(p = probs, df = 567, ncp = x)
}



###########################################################################

ggplot(cohenVar, aes(x = reorder(variable, -cohen.d), y = cohen.d))+
  geom_bar(stat = 'identity')+
  coord_flip()+
  geom_hline(yintercept = 0.8, color = 'red')+
  theme(axis.title = element_blank())
  

plot(cohenVar$cohen.d, EffectSize_df$average)

ggplot(EffectSize_df, aes(x = reorder(variable, -unequal), y = unequal))+
  geom_bar(stat = 'identity')+
  coord_flip()+
  geom_hline(yintercept = 0.8, color = 'red')+
  theme(axis.title = element_blank())
  

plot(cohenVar$cohen.d, EffectSize_df$unequal)
plot(cohenVar$cohen.d)

ggplot(EffectSize_df, aes(x = reorder(variable, -cohen_u1), y = cohen_u1))+
  geom_bar(stat = 'identity')+
  coord_flip()+
  geom_hline(yintercept = mean(EffectSize_df$cohen_u1), color = 'red')+
  theme(axis.title = element_blank())

ggplot(EffectSize_df, aes(x = reorder(variable, -cohen_u2), y =  cohen_u2))+
  geom_bar(stat = 'identity')+
  coord_flip()+
  geom_hline(yintercept = mean(EffectSize_df$cohen_u2), color = 'red')+
  theme(axis.title = element_blank())

ggplot(EffectSize_df, aes(x = reorder(variable, -cohen_u3), y = cohen_u3))+
  geom_bar(stat = 'identity')+
  coord_flip()+
  geom_hline(yintercept = mean(EffectSize_df$cohen_u3), color = 'red')+
  theme(axis.title = element_blank())

plot(cohenVar$cohen.d, EffectSize_df$proportion_3)

ggplot(EffectSize_df, aes(x = reorder(variable, -p_superiority), y = p_superiority))+
  geom_bar(stat = 'identity')+
  coord_flip()

ggplot(EffectSize_df, aes(x = reorder(variable, -p_overlap), y = p_overlap))+
  geom_bar(stat = 'identity')+
  coord_flip()

ggplot(EffectSize_df, aes(x = reorder(variable, -vd_a), y = vd_a))+
  geom_bar(stat = 'identity')+
  coord_flip()

ggplot(EffectSize_df, aes(x = reorder(variable, -wmw_ratio), y = wmw_ratio, fill = largest_cohen))+
  geom_bar(stat = 'identity')+
  coord_flip()+
  scale_fill_manual(values = c('TRUE' = 'red', 'FALSE' = 'grey'))

############################################################################

index <- splitData(df[1], splitRatio = 0.9)
validSet <- df[-index, ]
complement <- df[index, ]

ind <- splitData(complement, 0.9)
trainset = complement[ind, c(variables, 'diagnosis')]
testset = complement[-ind, c(variables, 'diagnosis')]

TopVariable <- function(x, ind, N){
  top <- top_n(x[, c(1, ind)], n = N)$variable
  return(top)
}
# d de cohen
svm_cohen<-svm(diagnosis~., data = trainSet, kernel='linear',
           type='C-classification')
predic<-predict(svm_cohen, newdata = testSet, probability = TRUE)

confusionMatrix(predic, testSet$diagnosis)

rocSVM<-roc(testSet$diagnosis~predic, plot=TRUE, print.auc=TRUE)
ggroc(rocSVM)

Accueracy : 0.9529         
Sensitivity : 0.9626          
Specificity : 0.9365 

# unequal 
svm_unequal<-svm(diagnosis~., data = trainSet, kernel='linear',
               type='C-classification')
predic<-predict(svm_unequal, newdata = testSet)
confusionMatrix(predic, testSet$diagnosis)

Accuracy : 0.9059  
Sensitivity : 0.9065          
Specificity : 0.9048 

# cohen_u1
svm_U1<-svm(diagnosis~., data = trainSet, kernel='linear',
                 type='C-classification')
predic<-predict(svm_U1, newdata = testSet)
confusionMatrix(predic, testSet$diagnosis)

Accuracy : 0.6118  
Sensitivity : 0.7290          
Specificity : 0.4127 

# cohen_u2
svm_U2<-svm(diagnosis~., data = trainSet, kernel='linear',
                 type='C-classification')
predic<-predict(svm_U2, newdata = testSet)
confusionMatrix(predic, testSet$diagnosis)

Accuracy : 0.9294 
Sensitivity : 0.9813         
Specificity : 0.8413

# cohen_u3
svm_U3<-svm(diagnosis~., data = trainSet, kernel='linear',
            type='C-classification')
predic<-predict(svm_U3, newdata = testSet)
confusionMatrix(predic, testSet$diagnosis)

Accuracy : 0.9647  
Sensitivity : 0.9907          
Specificity : 0.9206  