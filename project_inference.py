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
from math import isqrt
from itertools import islice, takewhile


def LouvainInference(graph):
    best_mod = -1
    communities = None
    for i in range(0,5):
        new_part = nx.community.louvain_communities(graph)
        mod = nx.community.modularity(graph,new_part)
        if mod > best_mod:
            best_mod = mod
            communities = new_part
    labels = {}
    for key, grp in enumerate(communities):
        for value in grp:
            labels[value] = key
    nx.set_node_attributes(graph, labels, "louvain")
    return list(communities)

def KarrerNewmanInference(graph,n_blocks):
    
    # best_mod = -1
    # best_sets = None
    for i in range(0,1):
        dc_partition = pysbm.NxPartition(graph=graph,
                                         number_of_blocks=n_blocks)
        karrer_newman_objective_function = pysbm.DegreeCorrectedUnnormalizedLogLikelyhood(is_directed=False)
        
        karrer_newman_inference = pysbm.KarrerInference(graph, karrer_newman_objective_function,
                                                        dc_partition, no_negative_move=True)
        
        karrer_newman_inference.infer_stochastic_block_model()
        
        block_assignments = dc_partition.get_block_memberships()
        node_list = sorted(dc_partition.partition.keys())
        block_dict = dict(zip(node_list, block_assignments))
            
        nx.set_node_attributes(graph,block_dict,"karrer")
            
        new_sets = {}
        for key, value in block_dict.items():
            if not value in new_sets:
                new_sets[value] = {key}  # we want the new dict to use lists of nodes for values
            else:
                new_sets[value].add(key)
                
        # mod = nx.community.modularity(graph,list(new_sets.values()))
        # if mod > best_mod:
        #     best_mod = mod
        #     best_sets = new_sets
    return list(new_sets.values())

def NewmanReinertInference(graph,n_blocks):
    
    # best_mod = -1
    # best_sets = None
    for i in range(0,1):
        dc_partition = pysbm.NxPartition(graph=graph,
                                         number_of_blocks=n_blocks)
        karrer_newman_objective_function = pysbm.NewmanReinertDegreeCorrected(is_directed=False)
        
        karrer_newman_inference = pysbm.KarrerInference(graph, karrer_newman_objective_function,
                                                        dc_partition, no_negative_move=True)
        
        karrer_newman_inference.infer_stochastic_block_model()
        
        block_assignments = dc_partition.get_block_memberships()
        node_list = sorted(dc_partition.partition.keys())
        block_dict = dict(zip(node_list, block_assignments))
            
        nx.set_node_attributes(graph,block_dict,"reinert")
            
        new_sets = {}
        for key, value in block_dict.items():
            if not value in new_sets:
                new_sets[value] = {key}  # we want the new dict to use lists for values
            else:
                new_sets[value].add(key)
        # mod = nx.community.modularity(graph,list(new_sets.values()))
        # if mod > best_mod:
        #     best_mod = mod
        #     best_sets = new_sets
    return list(new_sets.values())
    
def GirvanNewmanInference(graph):
    max_blocks = isqrt(graph.number_of_edges())
    comp = nx.community.girvan_newman(graph)
    limited = takewhile(lambda c: len(c) <= max_blocks, comp)
    communities = []
    for partition in limited:
        communities.append(partition)


    # Modularity -> measures the strength of division of a network into modules
    modularity_df = pd.DataFrame(
        [
            [k + 1, nx.community.modularity(graph, communities[k])]
            for k in range(len(communities))
        ],
        columns=["k", "modularity"],
    )
    best_idx = modularity_df["modularity"].idxmax()
    labels = {}
    for key, grp in enumerate(communities[best_idx]):
        for value in grp:
            labels[value] = key
    nx.set_node_attributes(graph, labels, "girvan")
    return communities[best_idx]

def InfomapInference(graph):
    im = Infomap(two_level=True, silent=True, num_trials=5)
    im.add_networkx_graph(graph)
    im.run()
    nx.set_node_attributes(graph, im.get_modules(), "infomap")
   
    communities = nx.get_node_attributes(graph,"infomap")
    sets = {}
    for key, value in communities.items():
        if not value in sets:
           sets[value] = {key}  # we want the new dict to use lists of nodes for values
        else:
            sets[value].add(key)
    modularity = nx.community.modularity(graph,list(sets.values()))

    return list(sets.values())
    