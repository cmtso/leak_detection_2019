#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed Nov 29 10:38:12 2017

@author: tsom
"""
import sys
import os
sys.path.append('/people/tsoc454/pflotran-dev/src/python') ## note does not support ~/pflotran, must type full path
import numpy as np
import matplotlib
import matplotlib.pyplot as plt
import math
import pflotran as pft
import fnmatch

#os.system('./shell/get-int.sh')

path = [] ## /home/tsom/Documents/DA_Michael/da_hydrogeophysics/da_hydrogeophysics2d/data/true
path.append(os.path.realpath('./shell/int'))
files = os.listdir(''.join(path))
filenames = pft.get_full_paths(path,files)

#path = [] 
#path.append('../shell')
#for file in os.listdir(''.join(path)):
#    if fnmatch.fnmatch(file, '*-int.dat'):
#        print (file)
#        filenametrue = file
#filenametrue = pft.get_full_paths(path,filenametrue)

path = [] ## /home/tsom/Documents/DA_Michael/da_hydrogeophysics/da_hydrogeophysics2d/data/true
path.append(os.path.realpath('./shell/int0'))
files = os.listdir(''.join(path))
filenames0 = pft.get_full_paths(path,files)

f = plt.figure(figsize=(6,6))
f.suptitle("Integral flux",fontsize=16)

ax=plt.subplot(2,1,1)
plt.xlabel('Time [d]')
plt.ylabel('mass_flux Tracer [mol/d]')
plt.title('Prior')

for ifile in range(len(filenames0)):
  data = pft.Dataset(filenames0[ifile],1,7)
  plt.plot(data.get_array('x'),data.get_array('y'),label=ifile)

plt.text(0.2, 0.1, '32 realizations',horizontalalignment='center', 
         verticalalignment='center', transform = ax.transAxes)
ax.axes.get_xaxis().set_visible(False)


ax=plt.subplot(2,1,2)
plt.xlabel('Time [d]')
plt.ylabel('mass_flux Tracer [mol/d]')
plt.title('Posterior')

#plt.xlim(0.,10.)
#plt.ylim(0.,1.)
#plt.grid(True)

for ifile in range(len(filenames)):
  data = pft.Dataset(filenames[ifile],1,7)
  plt.plot(data.get_array('x'),data.get_array('y'),label=ifile)

  
# true  
#data = pft.Dataset(filenametrue[0],1,7)   ### one-member list
#plt.plot(data.get_array('x'),data.get_array('y'),label=ifile)



plt.text(0.2, 0.1, '32 realizations',horizontalalignment='center', 
         verticalalignment='center', transform = ax.transAxes)
#'best'         : 0, (only implemented for axis legends)
#'upper right'  : 1,
#'upper left'   : 2,
#'lower left'   : 3,
#'lower right'  : 4,
#'right'        : 5,
#'center left'  : 6,
#'center right' : 7,
#'lower center' : 8,
#'upper center' : 9,
#'center'       : 10,
#==============================================================================
#plt.legend(loc=2,title='32 realizations')
# # xx-small, x-small, small, medium, large, x-large, xx-large, 12, 14
#plt.setp(plt.gca().get_legend().get_texts(),fontsize='medium')
# #      plt.setp(plt.gca().get_legend().get_texts(),linespacing=0.)
#plt.setp(plt.gca().get_legend().get_frame().set_fill(False))
#plt.setp(plt.gca().get_legend().draw_frame(False))
# #        plt.gca().yaxis.get_major_formatter().set_powerlimits((-1,1))
# 
#==============================================================================
f.subplots_adjust(hspace=0.2,wspace=0.2,
                  bottom=.12,top=.9,
                  left=.20,right=.93)

plt.savefig('results/img/mass_int.png')
#plt.show()

### plotting uncertainty bounds
### use fillbetween
### https://stackoverflow.com/questions/12957582/matplotlib-plot-yerr-xerr-as-shaded-region-rather-than-error-bars



