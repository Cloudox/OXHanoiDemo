#TencentTest

汉诺塔问题本身不难，主要是结合来做动画同时解决多个动画顺序执行的问题。

在做的过程中，耗时最长的也是动画依次执行这个问题，最终也没能找到很好地解决办法。

要达到一个动画执行完后再进行接下来的操作，我一开始想用信号量来等待直到动画执行完再继续往下执行代码，但是可能和主线程在跑的动画相冲突了，导致画面会卡死不动。

然后想到的是用延迟执行，将一个个动画的执行时间按照顺序往后延迟，但是似乎当量多了以后计时就会开始出现偏差，导致后来会出现问题，尝试了很多办法也依然没能解决。