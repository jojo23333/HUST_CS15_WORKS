
# coding: utf-8

# In[1]:


# 首先处理数据的格式，从三元组形式转化为稀疏矩阵的格式

import os
import sys
import scipy.sparse as sparse
import scipy.io

import numpy as np
import time
import math


# 函数需要两个输入参数，一个是原始三元组格式的输入文件，一个是输出的稀疏矩阵格式的名称
# 这里我们直接通过语料库做实验，以语料库作为输入，并用与语料库对应的文件处理

# corpus = sys.argv[1]
corpus = input('请选择一个语料库：')
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


# In[2]:

# 词汇表涵盖了语料库中的所有词语，需要将出现次数不多的词以及出现次数很多的词语去除

# 这里需要三个输入：文档词语稀疏矩阵，初始词汇表，截断值
# 我们直接使用语料库作为输入，将命名进行统一的标记
'''
if len(sys.argv) < 3:
    print('No enough input,please input the file and parameter')
    sys.exit()

input_matrix = sys.argv[1]  # 第一个输入即为之前得到的文档词语稀疏矩阵
full_Vocab = sys.argv[2]  # 第二个输入为初始的词汇表
cutoff = int(sys.argv[3])  # 第三个输入为设置的截断值
'''
# corpus = sys.argv[1]
#input_matrix = 'M_old.' + corpus + '.mat'
full_Vocab = 'vocab.' + corpus + '.txt'
# cutoff = sys.argv[2]
cutoff = int(input('请输入一个稀有词截断阈值：'))
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


# In[3]:

# 由于lil_matrix稀疏矩阵不便于统计剔除稀有词，可以转化为另一种csr_matrix稀疏矩阵
M = M.tocsr()
new_indptr = np.zeros(M.indptr.shape[0], dtype=np.int32)
new_indices = np.zeros(M.indices.shape[0], dtype=np.int32)
new_data = np.zeros(M.data.shape[0], dtype=np.int32)

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


# In[4]:

K = int(input('请输入主题数目：'))
from math import log

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



# In[5]:

import lda

model = lda.LDA(n_topics=K, n_iter=1000, alpha=0.5, random_state=np.random.randint(0,10))

model.fit(M.T)

A_LDA = model.topic_word_
np.savetxt(corpus+'_LDA_'+".A", A_LDA)

coherence_LDA = 0.0
Top = int(input('请选择需要的Top words的数目： '))

for k in range(K):
    topwords = np.argsort(A_LDA[k,:])[-Top:][::-1]
    #topwords = np.argpartition(-A[k,:],Top)[:Top]
    coherence_LDA += calculate_coherence(topwords, M)
print('Coherence Score: ', coherence_LDA / K)


# In[ ]:



