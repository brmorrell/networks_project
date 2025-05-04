import pysbm
import networkx as nx
import matplotlib.pyplot as plt
import matplotlib.pylab as pl
import matplotlib.cm as mplcm
import matplotlib.colors as colors
from os import listdir
from os.path import isfile, isdir, join
import sys
import os
import numpy as np
import pandas as pd
import csv
from infomap import Infomap
from sklearn import metrics

def outputNetStats(name,n,m,partitions,modularities):
    basics = [name,n,m]
    lengths = [len(p) for p in partitions]
    
    output = f"output/net_stats.csv"
    with open(output, "a", newline="", encoding="utf-8") as result:
        writer = csv.writer(result)
        row = basics + lengths + modularities
        writer.writerow(row)
    
def outputAMI(name,labels):
    scores = [name]
    for i in range(len(labels)):
        for j in range(len(labels)):
            scores.append(metrics.adjusted_mutual_info_score(labels[i],labels[j]))
    
    output = f"output/ami_vals.csv"
    with open(output, "a", newline="", encoding="utf-8") as result:
        writer = csv.writer(result)
        writer.writerow(scores)