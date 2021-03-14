# MiDeLoRa
Michael's Description Logic Reasoner Framework 

## About

Another piece of Common Lisp & CLIM (Common Lisp Interface Manager)
legacy software from my quarter century-old Lisp archive :-) It still
works flawlessly in 2021. Tested with LispWorks 6.1 & CLIM, on Ubuntu
Xenial, 32bit Motif port. Not sure about Windows. MiDeLoRa was
written between 2003 and 2005. 

Note that CLIM is not required, but if you have it, it will give you
some additional graphical tools, i.e., a taxonomy browser and ABox
visualizer. See `(require "clim")` in the `midelora-sysdcl.lisp`. 

MiDeLoRa is a framework and *DSL* (= *Domain Specific Language*, aka
*a set of Common Lisp macros* ;-)) for constructing Description Logic
Reasoners.  It also comes with a number of reasoners for standard DLs
(see `ls alc*` files in the
[`./src/midelora/prover/`](./src/midelora/prover/)
subdirectory). MiDeLoRa was part of my PhD thesis work.

Here is [a short paper detailing the main ideas behind
MiDeLoRa](http://citeseerx.ist.psu.edu/viewdoc/summary?doi=10.1.1.144.6295).
Full details can be found in my [PhD
thesis from 2005.](http://tubdok.tub.tuhh.de/handle/11420/834) 

How does the DSL, uhmm Common Lisp maro language look like?  Here is
an example of a prototypical ALCH DL prover, written in MiDeLoRa's 
DSL:

```
(define-prover ((abox-sat alch abox))
  (:init 

   (cond ((zerop (1- (no-of-nodes abox)))

          (loop-over-abox-nodes (node abox)
            (register-label-is-stable abox node))

          (with-strategy (+strategy+)
            (start-main)))

         (t 

          (perform (initial-abox-saturation)
            (:body
             (with-strategy (+abox-saturation-strategy+)
               (loop-over-abox-nodes (node abox)
                 (register-label-is-stable abox node))
               (perform (model-merging)
                 (:body
                  (start-main)))))))))

  (:main 
   (perform (deterministic-expansion)
     (:body 
      (if clashes 
          (handle-clashes)
        (perform (or-expansion)
          (:positive 
           (if clashes 
               (handle-clashes)           
             (restart-main)))
          (:negative 
           (perform (make-models-for-nodes)
             (:body 
              (perform (some-expansion)
                (:positive
                 (if clashes
                     (handle-clashes)
                   (perform (model-merging :node new-node)
                     (:body 
                      (next-round)))))
                (:negative 
                 (perform (make-models-for-old-nodes)
                   (:body 
                    (success)))))))))))))

  (:success    
   (completion-found)))
``` 

I would consider MiDeLoRa a *partial success* only. One of the ideas
behind it was to make it *fully object-oriented*, i.e., *everything*
was a CLOS instance: Tableaux nodes and edges, node and edge labels -
everything. The memory (heap) footprint was rather large. Given that
these (large) CLOS objects were destructively modified during the
Tableaux expansion / reasoning process, which sometimes required
backtracking, a *rollback history* of each Tableaux operations needed
to be kept. In case backtracking was required, this history was then 
used to revert and undo the operations and restore the object to
its previous state. A very expensive way of implementing backtracking
search. 

Nevertheless, it was an idea worth pursuing, and although
MiDeLoRa-defined DL reasoners were not nearly as fast as other
contenders of that time (Racer, Fact, ...) that used purely functional
and hence more light-weight data structures not requiring rollback
during backtracking, it was nevertheless fast enough to be used in
practical Description Logic ontology applications. For example, it was
used in [DLMAPS](https://github.com/lambdamikel/DLMAPS). It was also
possible to run the LUBM Benchmark with MiDeLoRa. See `(test 1)` here.
Moreover, in comparison to other reasoners of that time period,
MiDeLoRa did not have quite as many optimization techniques
implemented, and the ones implemented were the most basic ones
(semantic branching, dependency-directed backjumping, basic model
caching and merging, memoization & caching, ...). 

Back in these days, I was a big believer in CLOS and object-oriented +
functional programming in Common Lisp. Inspired by [the infamous
"Design Patterns" book from Gamma, Helm, Johnson,
Vlissides](https://www.amazon.com/Design-Patterns-Elements-Reusable-Object-Oriented/dp/0201633612#reader_0201633612),
and specifically by Chapter 2: "A Case Study: Designing a Document
Editor", where they take the object-orientied approach to the extreme
and represent even a single character as a class instance in the
"Lexi" document editor, I wanted to try the same approach for
realizing a DL reasoner. Specifically, the "Undo" history used for
"Lexi" was something needed for the backtracking. I had implemented
something similar previously, for [my object-oriented graphical editor
GenEd](https://github.com/lambdamikel/GenEd).

## Papers 

My [PhD thesis](http://tubdok.tub.tuhh.de/handle/11420/834) and [the book 
published by Logos](https://www.logos-verlag.de/cgi-bin/engbuchmid?isbn=2162&lng=deu&id=)
describe MiDeLoRa in detail. 

## Usage / Loading

Adjust the logical pathname translations in `midelora-sysdcl.lisp` to
match your environment. Then, simply do a load. To get started, try

```
(in-package :prover)
(sat? (and c d (some r e) (all r (not e))))
(test 1)
```

Enjoy! 

