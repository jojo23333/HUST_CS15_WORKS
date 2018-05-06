
# coding: utf-8

# In[ ]:


# 首先处理数据的格式，从三元组形式转化为稀疏矩阵的格式

import os
import sys
import scipy.sparse as sparse
import scipy.io

import numpy as np
import time
import math

import time
import sys
from numpy import *
import scipy.special as special
import multiprocessing
import scipy.stats as stats
from math import log
import datetime


# 函数需要两个输入参数，一个是原始三元组格式的输入文件，一个是输出的稀疏矩阵格式的名称
# 这里我们直接通过语料库做实验，以语料库作为输入，并用与语料库对应的文件处理

# corpus = sys.argv[1]
def main_proccess(corpus, cutoff, K, frag, f):
    print("corpus: %s, cutoff: %d, K: %d, frag %f" % (corpus, cutoff, K, frag))
    # corpus = input('请选择一个语料库：')
    os.chdir(corpus)

    input_file = 'docword.' + corpus + '.txt'
    infile = open(input_file)

    # 文档数量，单词表数量，语料库总词数
    num_docs = int(infile.readline())
    num_words = int(infile.readline())
    nnz = int(infile.readline())

    M = sparse.lil_matrix((num_words, num_docs))

    # 读取每一行，将三元组形式数据保存为稀疏矩阵(lil_matrix)
    for l in infile:
        d, w, v = [int(x) for x in l.split()]
        M[w-1, d-1] = v



    # In[ ]:

    # 词汇表涵盖了语料库中的所有词语，需要将出现次数不多的词以及出现次数很多的词语去除

    # 这里需要三个输入：文档词语稀疏矩阵，初始词汇表，截断值
    # 我们直接使用语料库作为输入，将命名进行统一的标记

    full_Vocab = 'vocab.' + corpus + '.txt'

    # cutoff = int(input('请输入一个稀有词截断阈值：'))
    # cutoff = 50
    # 读取语料库词汇表，并通过字典结构建立映射
    table = dict()
    numwords = 0  # 遍历词汇表，计算总的词语数目
    with open(full_Vocab, 'r') as file:
        for line in file:
            table[line.rstrip()] = numwords
            numwords += 1

    remove_word = [False]*numwords  # 利用一个列表判断哪些是需要去掉的词语

    # 读取停用词
    with open('stopwords.txt', 'r') as file:
        for line in file:
            if line.rstrip() in table:
                # 如果词汇表中的词也在停用词表中，则需要从词汇表中去掉这个词
                remove_word[table[line.rstrip()]] = True

    # 导入之前得到的文档词语稀疏矩阵，此时得到的是.mat文件，需要利用字典结构进行索引。
    #S = scipy.io.loadmat(input_matrix)
    #M = S['M']

    if M.shape[0] != numwords:
        print('Error: vocabulary file has different number of words', M.shape, numwords)
        print('The number of words in vocabulary file is: ',numwords)
        print('The number of words in doc-word file is: ',M.shape[0])
        sys.exit()
    print('Number of words is： ', numwords)   # 通过词汇表统计得到的词语数目
    numdocs = M.shape[1]
    print('Number of documents is： ', numdocs)  # 通过三元组统计得到的文档数目



    # In[ ]:

    # 由于lil_matrix稀疏矩阵不便于统计剔除稀有词，可以转化为另一种csr_matrix稀疏矩阵
    M = M.tocsr()
    new_indptr = np.zeros(M.indptr.shape[0], dtype=np.int32)
    new_indices = np.zeros(M.indices.shape[0], dtype=np.int32)
    new_data = np.zeros(M.data.shape[0], dtype=np.float64)

    indptr_counter = 1
    data_counter = 0

    # M.indptr.size - 1 表示稀疏矩阵的行数目，而行数目即等于词语数目
    # 由于采用的稀疏矩阵行表示词语，固在这里采用csr_matrix稀疏矩阵
    for i in range(M.indptr.size - 1):
        # 若不是停用词
        if not remove_word[i]:
            # 统计这个词出现的文档数目，这里利用的是csr_matrix矩阵的存储方式
            start = M.indptr[i]
            end = M.indptr[i + 1]

            # 若词语出现的文档数目大于设置的截断值，则词语保留
            # 其实这里还可以控制一下高频词
            if (end - start) >= cutoff and (end - start) <= numdocs*0.8:
                new_indptr[indptr_counter] = new_indptr[indptr_counter-1] + end - start
                new_data[new_indptr[indptr_counter-1]:new_indptr[indptr_counter]] = M.data[start:end]
                new_indices[new_indptr[indptr_counter-1]:new_indptr[indptr_counter]] = M.indices[start:end]
                indptr_counter += 1
            # 反之，则需要从词汇表中剔除该词语
            else:
                remove_word[i] = True

    new_indptr = new_indptr[0:indptr_counter]
    new_indices = new_indices[0:new_indptr[indptr_counter-1]]
    new_data = new_data[0:new_indptr[indptr_counter-1]]
    M = sparse.csr_matrix((new_data, new_indices, new_indptr))
    M = M.tocsc()


    # In[ ]:

    # 输出文件
    # 词语处理后的文档词语矩阵作为输出文件，在之前的文件名后添加.trunc后缀
    # 新的词汇表作为第二个输出文件，在之前的词汇表后添加.trunc后缀
    #output_matrix = 'M_new.' + corpus
    output_vocab = 'new_vocab.' + corpus + '.txt'

    # 仍然以csc_matrix稀疏矩阵保存
    #scipy.io.savemat(output_matrix, {'M' : M}, oned_as='column')

    print('New number of words is： ', M.shape[0])
    print('New number of documents is： ', M.shape[1])

    # 将得到的词汇表写入文件
    output = open(output_vocab, 'w')
    row = 0
    with open(full_Vocab, 'r') as file:
        for line in file:
            if not remove_word[row]:
                output.write(line)
            row += 1
    output.close()


    # In[ ]:

    # 通过给定的文档词语频数矩阵(CSC稀疏矩阵)计算词-词共现概率矩阵

    def Q_matrix(M):
        start_time = time.time()

        vocabSize = M.shape[0]  # 词汇表大小
        numdocs = M.shape[1]    # 文档数目
        diag_M = np.zeros(vocabSize)  # 创建初始矩阵

        for d in range(M.indptr.size - 1):
            # 对于文档d,其初始及结束索引
            start = M.indptr[d]
            end = M.indptr[d+1]

            nd = np.sum(M.data[start:end])
            row_indices = M.indices[start:end]

            if nd*(nd - 1) != 0:
                diag_M[row_indices] += M.data[start:end] / (nd*(nd-1))
                M.data[start:end] = M.data[start:end] / math.sqrt(nd*(nd-1))

        Q = M*M.transpose()/numdocs
        Q = Q.todense()
        Q = np.array(Q, copy=False)

        diag_M = diag_M/numdocs
        Q = Q - np.diag(diag_M)

        print("Sum of entries in Matrix Q is： ", np.sum(Q))
        print('Computing the matrix Q took:  %s seconds' % (str(time.time() - start_time)))

        return Q

    # corpus = sys.argv[1]  # 保存的文档词语稀疏矩阵

    # 调用上面定义的函数计算词语词语共现矩阵Q,
    Q = Q_matrix(M)

    # 利用贪心策略找最大边权的初始化group
    def greedy_init(Q, k):
        '''
        Args:
            Q: weights matrix(np.array)  # 权重矩阵（邻接矩阵）
            K: size of soft-clique(int)  # K-clique
            Return:
            (clique set, weight) tuple(set, float)    # 返回找的初始化clique以及此时的权重
        '''
        v_size = Q.shape[0]
        # s_pnt = Q.sum(axis = 0).argmin()
        s = {}
        v = []
        for i in range(k):
            s_pnt = int(np.random.choice(range(v_size), 1, replace=False))
            v = [s_pnt]
            for i in range(k-1):
                # print (Q)
                s_select = Q[v,:].sum(axis = 0)
                # print(s_select)
                s_select[v] = 1
                x = s_select.argmin()
                v.append(x)
                if (x in s):
                    s[x] += 1
                else:
                    s[x] = 1
        
        v = [id for id,val in s.items() if val>=k*frag]
        # assert(len(v) < k)

        print("Intersect :", len(v))
        v.sort()
        print(v)

        while len(v) > k:
            s_select = Q[v,:][:,v].sum(axis = 0)
            x = s_select.argmax()
            v.pop(x)

        while len(v) < k:
            s_select = Q[v,:].sum(axis = 0)
            # print(s_select)
            s_select[v] = 1
            x = s_select.argmin()
            v.append(x)

        return v

    # In[ ]:

    # 利用遗传策略的简单局部搜索算法找最大边权K-clique
    def simple_search(Q, K, s0=None, max_iter=500, log=True):
        '''
        Args:
            Q: weights matrix(np.array)  # 权重矩阵（邻接矩阵）
            K: size of soft-clique(int)  # K-clique
            s0: initial set(if None, intial set will be set randomly.) (list)  # 初始clique
            max_iter: max iteration time(if None, keep iteration until no optimization can be done.) (int)  # 最大迭代次数
            log: whether print out message each step(bool)   # 是否打印出每步的信息
        Return:
            (clique set, weight) tuple(set, float)    # 返回找的clique以及此时的权重
        '''
        v = Q.shape[0]
        if s0 is None:
            s = greedy_init(Q, K)
            # s = np.random.choice(range(v), K, replace=False)
        else:
            s = np.array(s0)
        s = np.sort(s)
        weights = np.sum(Q[s, :][:, s]) / 2
        delta = np.zeros((v, K))
        curk = Q[s, :][:, s]
        curk_sum = np.sum(curk, axis=1)

        return (s.tolist(), weights)

        for i in range(v):
            if i in s:
                continue
            delta[i] = np.sum(Q[i, s])
            delta[i] = delta[i] - Q[i, s]
            delta[i] = delta[i] - curk_sum

        iter = 0
        while True:
            # delta_min = next_node(delta, s)
            delta_min = int(np.argmin(delta))
            new_v, old_v = delta_min // K, delta_min % K

            if delta[new_v, old_v] < 0 and abs(delta[new_v, old_v]) > 1e-8:
                s_new = s.copy()
                s_new[old_v] = new_v
                s_new = np.sort(s_new)
                delta[s[old_v]] = np.sum(Q[s[old_v], s_new])
                delta[s[old_v]] -= Q[s[old_v], s_new]
                delta[s[old_v]] -= np.sum(Q[s_new, :][:, s_new], axis=1)
                new_weights = weights + delta[new_v, old_v]
                delta[new_v] = 0

                # update delta table
                for i in range(v):
                    if i in s_new or i == s[old_v]:
                        continue
                    delta[i] += Q[i, new_v] - Q[i, s[old_v]]
                    delta[i] += Q[i, s] - Q[i, s_new]
                    delta[i] += np.sum(Q[s, :][:, s], axis=1) - np.sum(Q[s_new, :][:, s_new], axis=1)
                if log:
                    print('%s -> %s\nweights:%.8f->%.8f' % (s, s_new, weights, new_weights))
                weights = new_weights
                s = s_new
            else:
                print("Iteration end at %d th turn" % iter)
                return (s.tolist(), weights)
            iter += 1
            if max_iter is not None and iter >= max_iter:
                break

        return (s.tolist(), weights)

    def adjust_clique(Q, K, s0, w, frag = 2.0, max_iter = 500):
        max_weights = Q[s0, :][:, s0].sum() / 2 * frag
        node_weights = Q.sum(axis=1)
        s = np.array(s0)
        k_node_weights = node_weights[s].sum()

        v = Q.shape[0]
        weights = np.sum(Q[s, :][:, s]) / 2
        delta = np.zeros((v, K))
        curk = Q[s, :][:, s]
        curk_sum = np.sum(curk, axis=1)

        for i in range(v):
            if i in s:
                continue
            delta[i] = np.sum(Q[i, s])
            delta[i] = delta[i] - Q[i, s]
            delta[i] = delta[i] - curk_sum

        print("max_iter: ",max_iter)

        for iter in range(max_iter):
            delta_min_pos = np.argmin(delta, axis=1)
            delta_min_val = np.array([delta[i][delta_min_pos[i]] for i in range(v)])
            delta_min_val[s] = 1

            new_v = -1
            while new_v == -1:
                x = np.argmin(delta_min_val)
                if delta_min_val[x] == 1:
                    break
                if x not in s and node_weights[x] > node_weights[s[delta_min_pos[x]]]:
                    new_v = x
                    old_v = delta_min_pos[x]
                delta_min_val[x] = 1

            if new_v == -1:
                print("no suitable node")
                return (s.tolist(), weights)

            if delta[new_v, old_v] + weights < max_weights:
                s_new = s.copy()
                s_new[old_v] = new_v
                s_new = np.sort(s_new)
                delta[s[old_v]] = np.sum(Q[s[old_v], s_new])
                delta[s[old_v]] -= Q[s[old_v], s_new]
                delta[s[old_v]] -= np.sum(Q[s_new, :][:, s_new], axis=1)
                new_weights = weights + delta[new_v, old_v]
                delta[new_v] = 0

                # update delta table
                for i in range(v):
                    if i in s_new or i == s[old_v]:
                        continue
                    delta[i] += Q[i, new_v] - Q[i, s[old_v]]
                    delta[i] += Q[i, s] - Q[i, s_new]
                    delta[i] += np.sum(Q[s, :][:, s], axis=1) - np.sum(Q[s_new, :][:, s_new], axis=1)
                # if log:
                #     print('%d->%d\nweights:%.8f->%.8f' % (old_v, new_v, weights, new_weights))
                weights = new_weights
                s = s_new
            else:
                print("Iteration end at %d th turn" % iter)
                return (s.tolist(), weights)

        print("reach max_iter")
        return (s.tolist(), weights)
            

    # In[ ]:

    Q[Q<0] = 0
    #Q2 = Q.copy()
    v = Q.shape[0]
    #pword = np.sum(Q, axis=1)

    Q2 = Q.copy()
    # 对角线元素置为0
    diag = Q2[range(v), range(v)]
    Q2[range(v), range(v)] = 0


    # In[ ]:

    # K = int(input('请输入主题数目：'))
    #K = 30
    st = time.clock()
    anchors, w = simple_search(Q2, K, log=False)
    et = time.clock()

    print("Using time:", et - st)

    # anchors, w = adjust_clique(Q2, K, anchors, w, frag=frag)
    
    # for i in range (5):
    #     anchors_t,w_t = simple_search(Q2, K, log=False)
    #     if w_t < w:
    #         anchors = anchors_t
    #         w = w_t

    vocab = open(output_vocab).read().strip().split()

    # for i,a in enumerate(anchors):
    #     print("第 %d 个anchor word是：%s" % (i+1, vocab[a]))

    print("Weights is %lf" % w)


    # In[ ]:

    anchor_words = open('Anchor_SC_'+corpus+'.txt','w')
    anchor_words_index = open('AnchorIndex_SC_'+corpus+'.txt','w')
    for i in anchors:
        anchor_words.write(vocab[i]+'\n')
        anchor_words_index.write(str(i)+'\n')
    anchor_words.close()
    anchor_words_index.close()


    # In[ ]:

    # 先定义一些辅助函数，计算中会用到的函数
    # import time
    # import sys
    # from numpy import *
    # import scipy.special as special
    # import multiprocessing
    # import scipy.stats as stats
    #from gurobipy import *


    def logsum_exp(y):
        m = y.max()
        return m + log((exp(y - m)).sum())

    def KL_helper(arg):
        p,q = arg
        if p == 0:
            return 0
        return p*(log(p)-log(q))

    def entropy(p):
        e = 0
        for i in range(len(p)):
            if p[i] > 0:
                e += p[i]*log(p[i])
        return -e
            

    def KL(p,log_p,q):
        N = p.size
        ret = 0
        log_diff = log_p - log(q)
        ret = dot(p, log_diff)
        if ret < 0 or isnan(ret):
            print("invalid KL!")
            print("p:")
            for i in range(n):
                print(p[i])
                if p[i] <= 0:
                    print("!!")
            print("\nq:")
            for i in range(n):
                print(q[i])
                if q[i] <= 0:
                    print("!!")
            if ret < 0:
                print("less than 0", ret)
            sys.exit(1)
        return ret


    # In[ ]:

    # 以L2作为误差度量方式时，此时的recovery过程
    #this method does not use a line search and as such may be faster
    #but it needs an initialization of the stepsize

    #  
    def fastQuadSolveExpGrad(y, x, eps, initialStepsize, recoveryLog, anchorsTimesAnchors=None): 
        (K,n) = x.shape

        # Multiply the target vector y and the anchors matrix X by X'
        #  (XX' could be passed in as a parameter)
        if anchorsTimesAnchors is None:
            print("XX' was not passed in")
            anchorsTimesAnchors = dot(x, x.transpose())
        targetTimesAnchors = dot(y, x.transpose())

        alpha = ones(K)/K
        log_alpha = log(alpha)

        iteration = 1 
        eta = 0.1 

        # To get the gradient, do one K-dimensional matrix-vector product
        proj = -2*(targetTimesAnchors - dot(alpha,anchorsTimesAnchors))
        new_obj = linalg.norm(proj,2)
        '''
        proj = -2*(targetTimesAnchors - dot(alpha,anchorsTimesAnchors)) + 2*alpha
        new_obj = linalg.norm(y-dot(alpha.transpose(),x),2) + linalg.norm(alpha,2)
        '''
        gap = float('inf')

        while 1:
        # Set the learning rate
            eta = initialStepsize/(iteration**0.5)
            iteration += 1

            # Save previous values for convergence tests
            old_obj = new_obj
            old_alpha = copy(alpha)

            # Add the gradient and renormalize in logspace, then exponentiate
            log_alpha += -eta*proj
            log_alpha -= logsum_exp(log_alpha)

            alpha = exp(log_alpha)
            
            # Recalculate the gradient and check for convergence
            proj = -2*(targetTimesAnchors - dot(alpha,anchorsTimesAnchors))
            new_obj = linalg.norm(proj,2)
            '''
            proj = -2*(targetTimesAnchors - dot(alpha,anchorsTimesAnchors)) + 2*alpha
            new_obj = linalg.norm(y-dot(alpha.transpose(),x),2) + linalg.norm(alpha,2)
            '''

            # Stop if the L2 norm of the change in alpha OR 
            #  the % change in L2 norm of the gradient are below tolerance.
            #convergence = min(linalg.norm(alpha-old_alpha, 2), abs(new_obj-old_obj)/old_obj)
            
            # stop if the primal-dual gap < eps
            lam = copy(proj)
            lam -= lam.min()

            gap = dot(alpha, lam)

            if gap < eps and iteration > 1:
                break

            if iteration % 10000 == 0:
                print("iter", iteration, "obj", old_obj, "gap", gap)

        return alpha, iteration, new_obj, None, gap


    # In[ ]:

    # 直接作为一个传统的二次凸优化问题进行求解
    def quadSolveExpGrad(y, x, eps, alpha=None, XX=None): 
        c1 = 10**(-4)
        c2 = 0.75
        if XX is None:
            print('making XXT')
            XX = dot(x, x.transpose())

        XY = dot(x, y)
        YY = float(dot(y, y))

        start_time = time.time()
        y_copy = copy(y)
        x_copy = copy(x)

        (K,n) = x.shape
        if alpha is None:
            alpha = ones(K)/K

        old_alpha = copy(alpha)
        log_alpha = log(alpha)
        old_log_alpha = copy(log_alpha)

        it = 1 
        aXX = dot(alpha, XX)
        aXY = float(dot(alpha, XY))
        aXXa = float(dot(aXX, alpha.transpose()))

        grad = 2*(aXX-XY)
        new_obj = aXXa - 2*aXY + YY
        '''
        grad = 2*(aXX-XY) + 2*alpha
        new_obj = aXXa - 2*aXY + YY + float(dot(alpha,alpha))
        '''

        old_grad = copy(grad)

        stepsize = 1
        repeat = False
        decreased = False
        gap = float('inf')
        while 1:
            eta = stepsize
            old_obj = new_obj
            old_alpha = copy(alpha)
            old_log_alpha = copy(log_alpha)
            if new_obj == 0:
                break
            if stepsize == 0:
                break

            it += 1
            #if it % 1000 == 0:
            #    print "\titer", it, new_obj, gap, stepsize
            #update
            log_alpha -= eta*grad
            #normalize
            log_alpha -= logsum_exp(log_alpha)
            #compute new objective
            alpha = exp(log_alpha)

            aXX = dot(alpha, XX)
            aXY = float(dot(alpha, XY))
            aXXa = float(dot(aXX, alpha.transpose()))

            old_obj = new_obj
            new_obj = aXXa - 2*aXY + YY
            '''
            new_obj = aXXa - 2*aXY + YY + float(dot(alpha,alpha))
            '''
            if not new_obj <= old_obj + c1*stepsize*dot(grad, alpha - old_alpha): #sufficient decrease
                stepsize /= 2.0 #reduce stepsize
                alpha = old_alpha 
                log_alpha = old_log_alpha
                new_obj = old_obj
                repeat = True
                decreased = True
                continue

            #compute the new gradient
            old_grad = copy(grad)
            grad = 2*(aXX-XY)
            '''
            grad = 2*(aXX-XY)+2*alpha
            '''
            
            if (not dot(grad, alpha - old_alpha) >= c2*dot(old_grad, alpha-old_alpha)) and (not decreased): #curvature
                stepsize *= 2.0 #increase stepsize
                alpha = old_alpha
                log_alpha = old_log_alpha
                grad = old_grad
                new_obj = old_obj
                repeat = True
                continue

            decreased = False

            lam = copy(grad)
            lam -= lam.min()
            
            gap = dot(alpha, lam)
            convergence = gap
            if (convergence < eps):
                break

        return alpha, it, new_obj, stepsize, gap


    # In[ ]:

    # 以KL作为误差度量方式时，此时的recovery过程
    # y denotes  , x denotes Q_sk, 
    def KLSolveExpGrad(y,x,eps, Ai, alpha=None):
        s_t = time.time()
        c1 = 10**(-4)
        c2 = 0.9
        it = 1 
        lamb = 0.1

        V = outV
        parax = 1.0
        
        start_time = time.time()
        y = clip(y, 0, 1)
        x = clip(x, 0, 1)

        (K,N) = x.shape
        mask = list(nonzero(y)[0])

        y = y[mask]
        x = x[:, mask]

        x += 10**(-9)
        x /= x.sum(axis=1)[:,newaxis]

        if alpha is None:
            alpha = ones(K)/K

        old_alpha = copy(alpha)
        log_alpha = log(alpha)
        old_log_alpha = copy(log_alpha)
        proj = dot(alpha,x)
        old_proj = copy(proj)

        log_y = log(y)
        
        new_obj = KL(y,log_y, proj)
        y_over_proj = y/proj
        grad = -dot(x, y_over_proj.transpose())
        old_grad = copy(grad)

        stepsize = 1
        decreasing = False
        repeat = False
        gap = float('inf')

        while 1:
            eta = stepsize
            old_obj = new_obj
            old_alpha = copy(alpha)
            old_log_alpha = copy(log_alpha)

            old_proj = copy(proj)

            it += 1
            #take a step
            log_alpha -= eta*grad

            #normalize
            log_alpha -= logsum_exp(log_alpha)

            #compute new objective
            alpha = exp(log_alpha)
            proj = dot(alpha,x)
            new_obj = KL(y,log_y,proj)
            if new_obj < eps:
                break

            grad_dot_deltaAlpha = dot(grad, alpha - old_alpha)
            assert (grad_dot_deltaAlpha <= 10**(-9))
            if not new_obj <= old_obj + c1*stepsize*grad_dot_deltaAlpha: #sufficient decrease
                stepsize /= 2.0 #reduce stepsize
                if stepsize < 10**(-6):
                    break
                alpha = old_alpha 
                log_alpha = old_log_alpha
                proj = old_proj
                new_obj = old_obj
                repeat = True
                decreasing = True
                continue

            
            #compute the new gradient
            old_grad = copy(grad)
            y_over_proj = y/proj
            grad = -dot(x, y_over_proj)

            if not dot(grad, alpha - old_alpha) >= c2*grad_dot_deltaAlpha and not decreasing: #curvature
                stepsize *= 2.0 #increase stepsize
                alpha = old_alpha
                log_alpha = old_log_alpha
                grad = old_grad
                proj = old_proj
                new_obj = old_obj
                repeat = True
                continue

            decreasing= False
            lam = copy(grad)
            lam -= lam.min()
            
            gap = dot(alpha, lam)
            convergence = gap
            if (convergence < eps):
                break

        regularItem = 0.0
        parax = 2.0
        a = parax/N + 1
        b = (N-1)*parax/N + 1
        betaAB = 1/special.beta(a,b)
        for i in range(K):
            regularItem += lamb*log(Ai[i]**(a-1) * (1-Ai[i])**(b-1)/betaAB)

        return alpha-regularItem, it, new_obj, stepsize, time.time()- start_time, gap



    # In[ ]:

    # recovery过程，由于有三种求解方式，通过选择不同的方式调用相应的求解函数解决对应的优化问题。
    def fastRecover(args):
        y,x,Ai,v,logfilename,anchors,divergence,XXT,initial_stepsize,epsilon = args
        start_time = time.time() 

        K = len(anchors)
        alpha = zeros(K)
        gap = None
        if v in anchors:
            alpha[anchors.index(v)] = 1
            it = -1
            dist = 0
            stepsize = 0

        else:
            try:
                if divergence == "KL":
                    alpha, it, dist, stepsize, t, gap = KLSolveExpGrad(y, x, Ai, epsilon)
                elif divergence == "L2":
                    alpha, it, dist, stepsize, gap = quadSolveExpGrad(y, x, Ai, epsilon, None, XXT)
                elif divergence == "fastL2":
                    alpha, it, dist, stepsize, gap = fastQuadSolveExpGrad(y, x, Ai,  epsilon, 100, None, XXT)

                else:
                    print("invalid divergence!")
                    if "gurobi" in divergence:
                        print("gurobi is only valid in single threaded")
                    assert(0)
                if isnan(alpha).any():
                    alpha = ones(K)/K

            except Exception as inst:
                print(type(inst))     # the exception instance
                print(inst.args)      # arguments stored in .args
                alpha =  ones(K)/K
                it = -1
                dist = -1
                stepsize = -1
                
        end_time = time.time()
        return (v, it, dist, alpha, stepsize, end_time - start_time, gap)


    # In[ ]:

    # 定义迭代求解器
    class myIterator:
        def __init__(self, Q, A, anchors, recoveryLog, divergence, v_max, initial_stepsize, epsilon=10**(-7)):
            self.Q = Q
            self.A = A
            self.anchors = anchors
            self.v = -1
            self.V_max = v_max
            self.recoveryLog = recoveryLog
            self.divergence = divergence
            self.X = self.Q[anchors, :]
            if "L2" in divergence:
                self.anchorsTimesAnchors = dot(self.X, self.X.transpose())
            else:
                self.anchorsTimesAnchors = None
            self.initial_stepsize = initial_stepsize
            self.epsilon = epsilon

        def __iter__(self):
            return self
        def next(self):
            self.v += 1
            # print "generating word", self.v, "of", self.V_max
            if self.v >= self.V_max:
                raise StopIteration
                return 0
            v = self.v
            Q = self.Q
            anchors = self.anchors
            divergence = self.divergence
            recoveryLog = self.recoveryLog
            return (copy(Q[v, :]), copy(A[v, :]), copy(self.X), v, recoveryLog, anchors, divergence, self.anchorsTimesAnchors, self.initial_stepsize, self.epsilon)


    # In[ ]:

    #takes a writeable file recoveryLog to log performance
    #comment out the recovery log if you don't want it
    def nonNegativeRecover(Q, anchors, outfile_name, divergence, max_threads, initial_stepsize=1, epsilon=10**(-7), delta=0.1):

        #topic_likelihoodLog = open(outfile_name+".topic_likelihoods", 'w')
        #word_likelihoodLog = open(outfile_name+".word_likelihoods", 'w')
        #alphaLog = open(outfile_name+".alpha", 'w')

        V = Q.shape[0]
        K = len(anchors)
        A = matrix(zeros((V,K)))

        # print(dot(Q, ones(V)))
        P_w = matrix(np.diag(dot(Q, ones(V))))
        for v in range(V):
            if isnan(P_w[v,v]):
                P_w[v,v] = 10**(-16)
        
        #normalize the rows of Q_prime
        for v in range(V):
            Q[v,:] = Q[v,:]/Q[v,:].sum()

        C = np.ones((V, K)) * (1.0/K)
        csum = np.sum(C, 1)
        for i in range(V):
            C[i,:] = C[i,:]/csum[i]
        pw = np.sum(Q, 1)
        A = np.diag(pw).dot(C)
        Asum = np.sum(A, 0)
        for i in range(K):
            A[:, i] = A[:, i]/Asum[i]

        deltaC = 1.0
        
        s = time.time()

        while deltaC < delta:
            oldC = C.copy()
            if max_threads > 0:
                pool = multiprocessing.Pool(max_threads)
                print("begin threaded recovery with", max_threads, "processors")
                args = myIterator(Q, A, anchors, outfile_name+".recoveryLog", divergence, V, initial_stepsize, epsilon)
                rows = pool.imap_unordered(fastRecover, args, chunksize = 10)
                for r in rows:
                    v, it, obj, alpha, stepsize, t, gap = r
                    C[v, :] = alpha
                    #if v % 1000 == 0:
                        #print "\t".join([str(x) for x in [v, it, max(alpha)]])
                        #print >>alphaLog, v, alpha
                        #alphaLog.flush()
                        #sys.stdout.flush()
            
            else:
                X = Q[anchors, :]
                XXT = dot(X, X.transpose())
                if divergence == "gurobi_L2":
                    scale = 1
                    model = Model("distance")
                    model.setParam("OutputFlag", 0)
                    alpha = [model.addVar() for _ in range(K)]
                    model.update()
                    #sum of c's is 1
                    model.addConstr(quicksum(alpha), GRB.EQUAL, 1)
                    for k in range(K):
                        model.addConstr(alpha[k], GRB.GREATER_EQUAL, 0)

                    o_static = QuadExpr()
                    for i in range(K):
                        for j in range(K):
                            o_static.addTerms(scale*XXT[i,j], alpha[i], alpha[j])

                    for w in range(V):
                        tol = 10**(-16)
                        model.setParam("BarConvTol", tol)
                        o = QuadExpr()
                        o += o_static
                        y = Q[w, :]
                        XY = dot(X, y)
                        YY = float(dot(y, y))
                        o += scale*YY
                        o += dot(-2*scale*XY, alpha)
                        model.setObjective(o, GRB.MINIMIZE)
                        model.optimize()
                        print("status", model.status)
                        while not model.status == 2:
                            tol *= 10
                            print("status", model.status, "tol", tol)
                            model.setParam("BarConvTol", tol)
                            model.optimize()
                        a = array([z.getAttr("x") for z in alpha])
                        C[w, :] = a
                        #print >>alphaLog, w, a
                        #print "alpha sum is", a.sum()
                        #print "solving word", w
                
                else:
                    for w in range(V):
                        y = Q[w, :]
                        v, it, obj, alpha, stepsize, t, gap= fastRecover((y,X,w,outfile_name+".recoveryLog",anchors,divergence,XXT,initial_stepsize, epsilon))
                        C[w, :] = alpha
                        #if v % 1 == 0:
                        #    print "word", v, it, "iterations. Gap", gap, "obj", obj, "final stepsize was", stepsize, "took", t, "seconds"
                        #    print >>alphaLog, v, alpha
                        #    alphaLog.flush()
                        sys.stdout.flush()

            deltaC = np.sum((oldC-C)**2)
            A = np.diag(pw).dot(C)
            Asum = np.sum(A, 0)
            for i in range(K):
                A[:, i] = A[:, i]/Asum[i]

        #rescale A matrix
        #Bayes rule says P(w|z) proportional to P(z|w)P(w)

        A = P_w * C

        #normalize columns of A. This is the normalization constant P(z)
        colsums = A.sum(0)

        for k in range(K):
            A[:, k] = A[:, k]/A[:,k].sum()
        
        A = array(A)
        return A, colsums, C


    # In[ ]:

    # 整个的recovery过程，

    #outV = 0

    # 执行recovery 过程，有三种方式，此处只选择两种比较典型的方式，L2和KL
    def do_recovery(Q, anchors, loss, params):
        #global outV
        V = Q.shape[0]
        # 以KL为误差度量的方式
        if loss == "KL":
            A, colsums, C = nonNegativeRecover(Q, anchors, params.log_prefix, loss, params.max_threads, V, epsilon=params.eps)
        # 以L2为误差度量的方式
        elif "L2" in loss:
            A, colsums, C = nonNegativeRecover(Q, anchors, params.log_prefix, loss, params.max_threads, V, epsilon=params.eps)
            #hp = colsums
            
        else:
            print("unrecognized loss function", loss, ". Options are KL,L2")
            return None
        
        return A, colsums, C


    # In[ ]:

    # 定义上面函数所需的一些参数
    class Params:

        def __init__(self, filename):
            self.log_prefix=None
            self.checkpoint_prefix=None
            self.seed = int(time.time())

            for l in open(filename):
                if l == "\n" or l[0] == "#":
                    continue
                l = l.strip()
                l = l.split('=')
                if l[0] == "log_prefix":
                    self.log_prefix = l[1]
                elif l[0] == "max_threads":
                    self.max_threads = int(l[1])
                elif l[0] == "eps":
                    self.eps = float(l[1])
                elif l[0] == "checkpoint_prefix":
                    self.checkpoint_prefix = l[1]
                elif l[0] == "new_dim":
                    self.new_dim = int(l[1])
                elif l[0] == "seed":
                    self.seed = int(l[1])
                elif l[0] == "anchor_thresh":
                    self.anchor_thresh = int(l[1])
                elif l[0] == "top_words":
                    self.top_words = int(l[1])


    # In[ ]:

    params = Params('settings.example')
    loss = 'L2'
    #loss = input('请选择L2 recovery还是KL recovery ： ')
    print(anchors)
    A, topic_likelihoods,C = do_recovery(Q, anchors, loss, params)


    # In[ ]:

    np.savetxt(corpus+'_SC_'+loss+".A", A)
    np.savetxt(corpus+'_SC_'+loss+".topic_likelihoods", topic_likelihoods)


    # In[ ]:

    # from math import log

    def calculate_coherence(tw,M):
        c = 0.0
        T = len(tw)
        for m in range(1,T):
            i = tw[m]
            for l in range(m):
                j = tw[l]
                sub = M[[i,j],:]
                D1 = np.nonzero(sub[1, np.nonzero(sub[0])[0]])[0].size
                D2 = np.nonzero(sub[1,:])[0].size
                c += log(float(D1 + 1e-8) / D2)
        return c


    # In[ ]:

    '''
    coherence = 0.0
    Top = int(input('请选择需要的Top words的数目： '))

    for k in range(K):
        topwords = np.argsort(A[:, k])[-Top:][::-1]
        coherence += calculate_coherence(topwords, M)
    print('Coherence Score: ', coherence / K)
    '''

    TopList = [5,10,15,20]
    coherence = [0]*len(TopList)

    for i in range(len(TopList)):
        Top = TopList[i]
        for k in range(K):
            topwords = np.argsort(A[:, k])[-Top:][::-1]
            coherence[i] += calculate_coherence(topwords,M)
        coherence[i] = coherence[i] / K
    print('主题一致性得分为：',coherence)
        


    # In[ ]:

    # 计算主题特异性
    def calculate_dissimilarity(M):
        K = M.shape[1]
        aver_M = np.sum(M,1) / K
        TD = [0]*K
        for i in range(K):
            TD[i] = linalg.norm(aver_M - M[:,i],2)
        dissimilarity = max(TD)
        return dissimilarity


    # In[ ]:

    dissimilarity = calculate_dissimilarity(A)
    print('主题特异性得分为：',dissimilarity)


    # In[ ]:

    def calculate_RE(M,Aw,C):
        V = M.shape[0]
        for v in range(V):
            M[v,:] = M[v,:]/M[v,:].sum()
        RE = 0
        for i in range(V):
            RE += linalg.norm(M[i,:] - dot(C[i,:],M[Aw,:]),2)
        RE = RE / V
        return RE 


    # In[ ]:

    RE = calculate_RE(Q,anchors,C)
    print("重构的平均误差为：",RE)
    
    # f.write(str(corpus)+',')
    f.write(str(cutoff)+",")
    f.write(str(K)+',')
    f.write(str(frag)+',')
    f.write(str(w)+',')
    f.write(str(coherence)+',')
    f.write(str(dissimilarity)+',')
    f.write(str(RE)+'\n')
    os.chdir("..")
    return (coherence, dissimilarity, RE)

# In[ ]:
if __name__ == '__main__':
    all_corpus = ["kos","nips"]
    all_cutoff = [50]
    all_k = [50,40,30]
    all_frag = [0.3, 0.4, 0.5, 0.6]#, 1.25, 1.5, 1.75, 2, 3, 4, 8]
    print("corpus",all_corpus)
    print("cut_off",all_cutoff)
    print("number of themes", all_k)
    print("frags" ,all_frag) 
    # 
    for corpus in all_corpus:
        nowTime=datetime.datetime.now().strftime('%Y_%m_%d_%H_%M')
        # sys.stdout = open("./"+corpus+'_test'+'/'+corpus+"_"+nowTime+".log",'w')
        f = open("./"+corpus+'_test'+'/'+corpus+"_"+nowTime+".res",'w')
        f.write("corpus: "+ str(all_corpus) + '\n')
        f.write("cut_off: " + str(all_cutoff) + '\n')
        f.write("number of themes: "+ str(all_k) + '\n')
        f.write("frags: " + str(all_frag) + '\n') 
        f.write("cutoff, clique size, frag, clique weights,主题一致性得分, 主题特异性得分, 重构的平均误差\n")
        for cutoff in all_cutoff:
            f.write("cutoff :" + str(cutoff) + " \n")
            for k in all_k:
                for frag in all_frag:
                    coherence = np.array(zeros((5, 4)))
                    dissimilarity = np.array([0,0,0,0,0])
                    RE = np.array([0,0,0,0,0])
                    coherence[0,:], dissimilarity[0], RE[0] = main_proccess(corpus, cutoff, k, frag, f)
                    coherence[1,:], dissimilarity[1], RE[1] = main_proccess(corpus, cutoff, k, frag, f)
                    coherence[2,:], dissimilarity[2], RE[2] = main_proccess(corpus, cutoff, k, frag, f)
                    coherence[3,:], dissimilarity[3], RE[3] = main_proccess(corpus, cutoff, k, frag, f)
                    coherence[4,:], dissimilarity[4], RE[4] = main_proccess(corpus, cutoff, k, frag, f)
                    coherence_aver = np.average(coherence, axis=0)
                    dissimilarity_aver = np.average(dissimilarity)
                    RE_aver = np.average(RE)
                    # f.write(str(corpus)+',')
                    f.write(str(cutoff)+",")
                    f.write(str(k)+',')
                    f.write(str(frag)+',')
                    f.write(',')
                    f.write(str(coherence_aver.tolist())+',')
                    f.write(str(dissimilarity_aver)+',')
                    f.write(str(RE_aver)+'\n')
                    f.write('\n')
                f.write('\n')
            f.write('\n')
        sys.stdout.close()
        f.close()



