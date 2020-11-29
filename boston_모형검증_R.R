library(tidyverse)

# 주어진 housing.data로 파이썬에서 csv 파일 제작해 불러와 사용
# housing <- read_csv('housing.csv')
# set.seed(42)
# sample_num = sample(1:nrow(housing), size = round(0.2 * nrow(housing)))
# housing_test = housing[ sample_num, ]
# housing_train = housing[-sample_num, ]

## 파이썬에서 만든 모델과 동일한 train, test 데이터 사용 필요!
## csv로 제작한 해당 train, test 데이터를 불러와 모델의 통계 검증 진행


housing_train <- read_csv('housing_model_train.csv')
housing_test <- read_csv('housing_model_test.csv')

glimpse(housing_train)

# 파이썬 파일에서 최종적으로 선택한 변수를 사용해 모델 구성 후 검증 실시
# RM         0.404314
# LSTAT      0.367514
# DIS        0.084744
# NOX        0.037223
# PTRATIO    0.034440
# CRIM       0.027594
model <- lm(MEDV ~ RM + LSTAT + DIS + NOX + PTRATIO + CRIM, data=housing_train)

summary(model)
# 모델 및 변수 전부 통계적으로 문제 없음

plot(model)
# 1) Residual vs. Fitted : 일정한 구조나 패턴이 보이지 않으므로 등분산성 문제 없음
# 2) Normal QQ : 직선에 가까우므로 오차의 정규분포 가정을 만족함
# 3) Scale-Location : 적합값이 증가함에 따라 나타나는 삼각형 패턴이 보이지 않으므로 문제 없음
# 4) Residual-Leverage : 0.5가 넘는 점이 없으므로 역시 문제 없음

## 따라서 본 모델은 선형회귀분석의 가정을 통계적으로 만족하여 문제 없음



### 참고 : p-value에 의한 변수선택 이슈

# p-value에 대한 이슈 및 본 분석에서 p-value에 의지하지 않을 것임은 파이썬 분석에서 상술하였음
# 그러나 p-value에만 의지할 경우 발생하는 문제점을 공유하기 위해
# 이제부터 p-value에 의존한 변수 선택을 예시로 진행하고자 함


### 아래 내용은 이전 진행한 내용으로, 현재 상황과는 다르므로 참고만 부탁드립니다
### p-value 기준으로 변수 선택할때는 진행할때마다 달라져서 재현이 안되네요.

housing <- read_csv('housing.csv')
set.seed(42)
sample_num = sample(1:nrow(housing), size = round(0.2 * nrow(housing)))
housing_test = housing[ sample_num, ]
housing_train = housing[-sample_num, ]


model <- lm(MEDV ~ RM + LSTAT + PTRATIO + NOX + CRIM + AGE + INDUS + TAX, data=housing_train)
summary(model)
## 현 단계에서, 단순히 p-value에만 의지한 변수 선택에 의하면 RM, LSTAT, AGE만으로 구성하여야 함
## 우선 p-value가 가장 큰 TAX 제거

model1 <- lm(MEDV ~ RM + LSTAT + PTRATIO + NOX + CRIM + AGE + INDUS, data=housing_train)
summary(model1)
##p-value가 가장 큰 INDUS 제거

model2 <- lm(MEDV ~ RM + LSTAT + PTRATIO + NOX + CRIM + AGE, data=housing_train)
summary(model2)
##p-value가 가장 큰 NOX 제거

model3 <- lm(MEDV ~ RM + LSTAT + PTRATIO + CRIM + AGE, data=housing_train)
summary(model3)
##p-value가 가장 큰 NOX 제거


## MEDV ~ RM + LSTAT + PTRATIO + CRIM + AGE
# 주택 가격은 평균 방 갯수, 1940년 이전에 지어진 집들의 비율이 높아질수록 상승한다
# 주택 가격은 저소득 주민들의 비율, 학생-선생 비율, 범죄율이 높아질수록 하락한다.

# 이러한 결론을 도출하는 데는 통계적으로 문제가 없다.
# 그러나 강변에 있는지 여부, 고용중심으로부터의 거리, 고속도로에의 접근 용이성 등
# 경험적으로 알수 있는 요소가 집값에 미치는 영향을 반영하지 않은 이유에 대해 
# 과연 '통계적으로 무의미함' 이라는 말로 해결된다고 할 수 있을까?

# 분석은 페이퍼상의 숫자를 넘어, 우리가 사는 세상과 비즈니스에서 인사이트를 얻고
# 그를 통해 더 좋은 세상을 만들고 비즈니스를 개선하기 위해 행해져야 한다.

# 따라서 본 분석에서는 
# 1) '현상'에 영향을 미치는 중요한 변수를 찾기 위해 트리기법을 사용하고
# 2) 그 결과로 구성한 모델을 해석하는데는 선형회귀의 설명방식을 활용하는
# 2단계 방식을 적용하였다. (파이썬 파일 참조)

# > 참고자료
## p-value는 연구 가설이 참일 확률이나 데이터가 오로지 우연으로 생성되었을 확률을 측정하지 않는다.
## p-value가 특정 임계점을 통과했는가가 단독으로 과학적 결론이나 사업적/정책적 결정을 내리는 근거가 되어서는 안 된다.
## 적절한 추론에는 "완전한 보고와 투명성"이 필요하다.
## p-value, 혹은 통계적 유의성은 "효과의 크기"나 "결과의 중요성"을 측정하지 않는다.
## p-value 자체는 모형이나 가설에 관련한 증거에 대한 훌륭한 척도를 제공하지 않는다.
## https://www.editage.co.kr/insights/is-my-research-significant-why-you-shouldn%E2%80%99t-rely-on-p-values

## (통계적 유의성과 과학적, 실질적, 또는 임상적 유의성은 서로 같지 않습니다.)
