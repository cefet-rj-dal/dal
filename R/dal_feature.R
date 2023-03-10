# DAL Library
# version 2.1

# depends dal_transform.R

### Feature Selection
# loadlibrary("leaps")
# loadlibrary("glmnet")
# loadlibrary("FSelector")
# loadlibrary("doBy")

#'@title Feature Selection
#'@description
#'@details
#'
#'@param attribute
#'@return
#'@examples
#'@export
feature_selection <- function(attribute) {
  obj <- dal_transform()
  obj$attribute <- attribute
  class(obj) <- append("feature_selection", class(obj))
  return(obj)
}

#'@export
transform.feature_selection <- function(obj, data) {
  data = data[,c(obj$features, obj$attribute)]
  return(data)
}

#Lasso
#'@title Feature Selection using Lasso regression
#'@description
#'@details
#'
#'@param attribute
#'@return
#'@examples
#'@export
feature_selection_lasso <- function(attribute) {
  obj <- feature_selection(attribute)
  class(obj) <- append("feature_selection_lasso", class(obj))
  return(obj)
}

#'@import glmnet
#'@export
fit.feature_selection_lasso <- function(obj, data) {
  data = data.frame(data)
  if (!is.numeric(data[,obj$attribute]))
    data[,obj$attribute] =  as.numeric(data[,obj$attribute])

  nums = unlist(lapply(data, is.numeric))
  data = data[ , nums]

  predictors_name  = setdiff(colnames(data), obj$attribute)
  predictors = as.matrix(data[,predictors_name])
  predictand = data[,obj$attribute]
  grid = 10^seq(10, -2, length = 100)
  cv.out = glmnet::cv.glmnet(predictors, predictand, alpha = 1)
  bestlam = cv.out$lambda.min
  out = glmnet::glmnet(predictors, predictand, alpha = 1, lambda = grid)
  lasso.coef = predict(out,type = "coefficients", s = bestlam)
  l = lasso.coef[(lasso.coef[,1]) != 0,0]
  vec = rownames(l)[-1]

  obj$features <- vec

  return(obj)
}

# forward stepwise selection
#'@title
#'@description
#'@details
#'
#'@param attribute
#'@return
#'@examples
#'@export
feature_selection_fss <- function(attribute) {
  obj <- feature_selection(attribute)
  class(obj) <- append("feature_selection_fss", class(obj))
  return(obj)
}

#'@export
fit.feature_selection_fss <- function(obj, data) {
  data = data.frame(data)
  if (!is.numeric(data[,obj$attribute]))
    data[,obj$attribute] =  as.numeric(data[,obj$attribute])

  nums = unlist(lapply(data, is.numeric))
  data = data[ , nums]

  predictors_name  = setdiff(colnames(data), obj$attribute)
  predictors = as.matrix(data[,predictors_name])
  predictand = data[,obj$attribute]

  regfit.fwd = regsubsets(predictors, predictand, nvmax=ncol(data)-1, method="forward")
  summary(regfit.fwd)
  reg.summaryfwd = summary(regfit.fwd)
  b1 = which.max(reg.summaryfwd$adjr2)
  t = coef(regfit.fwd,b1)
  vec = names(t)[-1]

  obj$features <- vec

  return(obj)
}

# information gain
#'@title
#'@description
#'@details
#'
#'@param attribute
#'@return
#'@examples
#'@export
feature_selection_ig <- function(attribute) {
  obj <- feature_selection(attribute)
  class(obj) <- append("feature_selection_ig", class(obj))
  return(obj)
}

#'@export
fit.feature_selection_ig <- function(obj, data) {
  data <- data.frame(data)
  data[,obj$attribute] = as.factor(data[, obj$attribute])

  class_formula <- formula(paste(obj$attribute, "  ~ ."))
  weights <- information.gain(class_formula, data)

  tab <- data.frame(weights)
  tab <- orderBy(~-attr_importance, data=tab)
  tab$i <- row(tab)
  tab$import_acum <- cumsum(tab$attr_importance)
  myfit <- fit_curvature_min()
  res <- transform(myfit, tab$import_acum)
  tab <- tab[tab$import_acum <= res$y, ]
  vec <- rownames(tab)

  obj$features <- vec

  return(obj)
}

# relief
#'@title
#'@description
#'@details
#'
#'@param attribute
#'@return
#'@examples
#'@export
feature_selection_relief <- function(attribute) {
  obj <- feature_selection(attribute)
  class(obj) <- append("feature_selection_relief", class(obj))
  return(obj)
}

#'@export
fit.feature_selection_relief <- function(obj, data) {
  data <- data.frame(data)
  data[,obj$attribute] = as.factor(data[, obj$attribute])

  class_formula <- formula(paste(obj$attribute, "  ~ ."))
  weights <- relief(class_formula, data)

  tab <- data.frame(weights)
  tab <- orderBy(~-attr_importance, data=tab)
  tab$i <- row(tab)
  tab$import_acum <- cumsum(tab$attr_importance)
  myfit <- fit_curvature_min()
  res <- transform(myfit, tab$import_acum)
  tab <- tab[tab$import_acum <= res$y, ]
  vec <- rownames(tab)

  obj$features <- vec

  return(obj)
}
