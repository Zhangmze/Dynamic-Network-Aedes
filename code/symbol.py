from gplearn.genetic import SymbolicRegressor
from sklearn.ensemble import RandomForestRegressor
from sklearn.tree import DecisionTreeRegressor
from sklearn.utils.random import check_random_state
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from sklearn.preprocessing import MinMaxScaler
from gplearn.functions import make_function
# Training samples
import numpy
name = "./networkresult.csv"
df = pd.read_csv(name)
def _sigmoid(x1,x2):
    with np.errstate(over='ignore', under='ignore'):
        c = (16-x2)/(1 + np.exp(-x1))+4+x2
        c = c*(c>-1000)
        c = c*(c<1000)
        c = np.nan_to_num(c, nan=-1000)
        return c
sig = make_function(function=_sigmoid, name='sig', arity=2)
function_set=['add', 'sub', 'mul', 'div',sig]
x_train = df[['x1','x2']]
y_train = df['x3']
est_gp =SymbolicRegressor(population_size=6000,
                           generations=40,stopping_criteria=0.01,
                           p_crossover=0.5,p_subtree_mutation=0.1,
                          p_hoist_mutation=0.07, p_point_mutation=0.1,
                           max_samples=0.8,verbose=1,
                          parsimony_coefficient=0.02, random_state=0,function_set=function_set)
est_gp.fit(x_train, y_train)
print (est_gp._program)

from IPython.display import Image

import pydotplus
import os       
os.environ["PATH"] += os.pathsep + 'D:/Graphviz/bin' 
graph = est_gp._program.export_graphviz()
graph = pydotplus.graphviz.graph_from_dot_data(graph)
Image(graph.create_png())

xx=np.linspace(0,200,200)
tem = [15,24,28,30,32,35]
scaler = MinMaxScaler()

for j in range(1,7):
    plt.subplot(2,3,j)
    z = []
    for i in xx:
        z.append(est_gp.predict([[tem[j-1],i]]).tolist())
    plt.plot(xx,z)

xx=np.linspace(15,35,20)
rain = [0,5,10,15,20,25,50,100,200]
for j in range(1,10):
    plt.subplot(3,3,j)
    z = []
    for i in xx:
        z.append(est_gp.predict([[i,rain[j-1]]]).tolist())
    plt.plot(xx,z)

name = "./networktest.csv"
df = pd.read_csv(name)
x_test = df[['x1','x2']]
y_test = df['x3']
# 在测试集上评估最佳表达式
y_test_pred = est_gp.predict(x_test)
test_mse = mean_squared_error(y_test, y_test_pred)
test_mae = mean_absolute_error(y_test, y_test_pred)
test_r2 = r2_score(y_test, y_test_pred)

print(f'Test MSE: {test_mse}')
print(f'Test MAE: {test_mae}')
print(f'Test R²: {test_r2}')