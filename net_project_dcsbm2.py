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
from math import isqrt
import csv
import project_inference
import project_hists


mypath = sys.argv[1]
onlyfiles = [f for f in listdir(mypath) if isfile(join(mypath, f))]


for f in onlyfiles:
    print("opening "+str(f))
    if not f.endswith(".DS_Store"):
        netfile_name = join(mypath,f)
        print(f)
        graph = None
        if netfile_name.endswith(".txt"):
            net = pd.read_csv(netfile_name)
            trimmed= [s.strip().lower() for s in net.columns]
            net.columns = trimmed
            
            graph = nx.from_pandas_edgelist(net, 'src', 'dst')
        if netfile_name.endswith(".csv"):
            net = pd.read_csv(netfile_name)
            adjacency = net[2:][1:]
            
            rows, cols = np.where(adjacency == 1)
            edges = zip(rows.tolist(), cols.tolist())
    
            
            # And drop the silly first andlast columns
            #net.drop(['~', ';'], axis=1, inplace=True)
            graph = nx.Graph()
            graph.add_edges_from(edges)
            
        
        n = graph.number_of_nodes()
        m = graph.number_of_edges()
        
        '''
        Inference portion
        '''
        partitions = []
        modularities = []
        labels = []
        sorted_nodes = list(graph.nodes)
        sorted_nodes.sort()
        print("beginning louvain")
        partitions.append(project_inference.LouvainInference(graph))
        modularities.append(nx.community.modularity(graph,partitions[0]))
        attrs = nx.get_node_attributes(graph,"louvain")
        label_set = [0]*len(sorted_nodes)
        for i in sorted_nodes:
            label_set.append(attrs[i])
        labels.append(label_set)
        n_blocks = len(partitions[0])
        
        print("beginning karrer")
        partitions.append(project_inference.KarrerNewmanInference(graph,n_blocks))
        modularities.append(nx.community.modularity(graph,partitions[1]))
        attrs = nx.get_node_attributes(graph,"karrer")
        label_set = [0]*len(sorted_nodes)
        for i in sorted_nodes:
            label_set.append(attrs[i])
        labels.append(label_set)
        print("beginning reiner")
        partitions.append(project_inference.NewmanReinertInference(graph,n_blocks))
        modularities.append(nx.community.modularity(graph,partitions[2]))
        attrs = nx.get_node_attributes(graph,"reinert")
        label_set = [0]*len(sorted_nodes)
        for i in sorted_nodes:
            label_set.append(attrs[i])
        labels.append(label_set)
        '''
        print("beginning girvan")
        partitions.append(project_inference.GirvanNewmanInference(graph))
        modularities.append(nx.community.modularity(graph,partitions[3]))
        attrs = nx.get_node_attributes(graph,"girvan")
        label_set = [0]*len(sorted_nodes)
        for i in sorted_nodes:
            label_set.append(attrs[i])
        labels.append(label_set)
        '''
        print("beginning infomap")
        partitions.append(project_inference.InfomapInference(graph))
        modularities.append(nx.community.modularity(graph,partitions[3]))
        attrs = nx.get_node_attributes(graph,"infomap")
        label_set = [0]*len(sorted_nodes)
        for i in sorted_nodes:
            label_set.append(attrs[i])
        labels.append(label_set)
        
        
        '''
        Output per-network info and AMI
        '''
        
        project_hists.outputNetStats(str(f),n,m,partitions,modularities)
        project_hists.outputAMI(str(f),labels)
        
        
        
        
        
    
    