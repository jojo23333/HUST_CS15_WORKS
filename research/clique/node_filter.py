import sys, getopt
import os
import numpy as np

# -g -t (--graph --thresh)
def main(argv):
	graph_file = ''
	threshold = 0.0
	try:
		opts, args = getopt.getopt(argv, "hg:t:", ["graph==","threshold=="])
	except getopt.GetoptError:
		print('usage -g <graph_matrix_file> -t <threshold>')
		sys.exit(2)

	for opt, arg in opts:
		if opt == '-h':
			print('usage -g <graph_matrix_file> -t <threshold>')
			sys.exit(2)
		elif opt in ("-g", "--graph"):
			graph_file = arg
		elif opt in ("-t", "--threshold"):
			threshold = arg
	
	if graph_file == '':
		print('usage -g <graph_matrix_file> -t <threshold>')
		sys.exit(2)
	
	threshold = float(threshold)

	graph = np.loadtxt(graph_file)
	gsize = graph.shape[0]
	nodemap = {}
	edgelist = []
	nid = 1
	nidlist = np.darray()

	for i in range(gsize):
		for j in range(i+1,gsize):
			if graph[i][j] <= threshold:
				if i not in nodemap:
					nodemap[i] = nid
					nid += 1
					nidlist.append(i)
				if j not in nodemap:
					nodemap[j] = nid
					nid += 1
					nidlist.append(j)
				edgelist.append([i,j])
	
	f = open("graph.dimacs","w")
	f.write("p edge " + str(len(nodemap)) + " " + str(len(edgelist)) + '\n')
	for u,v in edgelist:
		f.write("e " + str(nodemap[u]) + " " + str(nodemap[v]) + '\n')
	f.close()

	os.system("./a.out graph.dimacs")
	nodes = np.readtxt("max_clique","r")
	nid = nidlist[nodes-1]
	min_w = 1
	min_g = []
	for i in range(nid.shape[0]):
		id = nid[i,:]
		w = graph[id,:][:,id].sum()
		if w > min_w:
			min_w = w
			min_g = nid[i,:]

if __name__ == '__main__':
	main(sys.argv[1:])