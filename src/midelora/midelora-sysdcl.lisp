;;; -*- Mode: LISP; Syntax: Common-Lisp; Package: CL-USER -*-

(in-package :cl-user)

(eval-when (:compile-toplevel :load-toplevel :execute)
  (declaim
   (optimize
    (safety 0)		        ; Run time error checking level
    (speed 3)			; Speed of the compiled code
    (compilation-speed 0)         ; Speed of compilation
    (space 0)			; Space of both intermediate files and object
    (debug 0)
    )))

;;;
;;;
;;; 

(setf (logical-pathname-translations "base")
        (list '("**;*.*" "~mwessel/midelora/**/*.*")))
  
(setf (logical-pathname-translations "midelora")
      (list '("fonts;*.*" "base:db;*.*")
            '("code;*.*" "base:*.*")
            '("**;*.*" "base:**;*.*")))
    
(setf (logical-pathname-translations "nrql-dev")
      (list '("**;*.*" "midelora:query;**;*.*")))

;;;
;;;
;;; 

(load "midelora:define-system.lisp")

(setf system::*sg-default-size* (* 10 16000))

(setf *print-length* nil)

;;;
;;;
;;; 

(defun lracer (&optional (force-p nil))
  (declare (ignorable force-p))
  (setf (logical-pathname-translations "lracer")
        (list '("**;*.*" "midelora:lracer;**;*.*")))
  (push :lracer *features*)  
  (load "lracer:lracer-sysdcl.lisp")
  (compile-load-lracer))

(defun prover-dev (&optional (force-p nil))
  (load "base:define-system.lisp")
  (push :midelora *features*) 
  (push :debug *features*)
  (push :dlmaps *features*)
  (push :nrql-dev *features*)
  (load "nrql-dev:nrql-sysdcl.lisp")
  (lracer force-p)
  (load "midelora:query;queries-sysdcl.lisp")
  (compile-system 'prover :load t :force force-p))

;;;
;;;
;;; 

(define-system packages
  (:default-pathname "midelora:")
  (:serial
   "dlmaps-packages4"))

(define-system persistence 
  (:default-pathname "midelora:persistence;")
  (:serial 
   packages
   "persistence3"))

(define-system logic-tools 
  (:default-pathname "midelora:tools;")
  (:serial 
   packages
   "tools"
   "logic-tools"))

(define-system tools 
  (:default-pathname "midelora:tools;")
  (:serial 
   packages
   "grapher"
   #+:clim "class-browser"
   "tools"
   logic-tools
   #+:clim "gui-tools"
   #+:clim "fonts"))

(define-system heap 
  (:default-pathname "midelora:tools;")
  (:serial 
   "heap"))

(define-system dag 
  (:default-pathname "midelora:tools;")
  (:serial 
   packages
   "dag3"))

(define-system racer-dag 
  (:default-pathname "midelora:tools;")
  (:serial 
   packages
   dag
   "racer-dag"))


(define-system basic-graph
  (:default-pathname "midelora:basic-graph;")
  (:serial 
   packages
   persistence 
   tools
   "basic-graph"))

#+:clim
(define-system graph-visualizer
  (:default-pathname "midelora:graph-visualizer;")
  (:serial 
   basic-graph
   "graph-visualizer3"))

(define-system thematic-substrate
  (:default-pathname "midelora:thematic-substrate;")
  (:serial 
   packages
   #+:clim graph-visualizer
   #-:clim basic-graph
   ;; "process"
   "racer-conversions3"
   "descriptions5"
   "substrate7"
   "rolebox"
   "rolebox-substrate6"
   "jepd-substrate4"
   ))

(define-system racer-substrate
  ;;; nicht individuell compilierbar!
  (:default-pathname "midelora:thematic-substrate;")
  (:serial                
   "common15"
   "racer-substrate5"))

(define-system tables
  (:default-pathname "midelora:tables;")
  (:serial 
   packages
   "tables"))

(define-system dl-benchmark
  (:default-pathname "midelora:prover;dl-benchmark-suite;")
  (:serial 
   "dlmaps-tests"
   "dl-tests"))

(define-system prover
  (:default-pathname "midelora:prover;")
  (:serial 
   packages
   heap
   dag
   racer-dag
   #+:clim graph-visualizer
   thematic-substrate
   tables
   "settings"
   "specials"  
   "languages"
   "macros"
   "syntax9"
   "abstractions"
   "strategy"
   "abox9"    
   "node-label2"
   "edge-label"
   "abox-nodes"
   "abox-edges"
   "tools"
   "kernel16"
   "node-management"
   "edge-management"
   ;"delete"
   "concept-selection13"
   "merging2"
   "creators"
   "abox-interface"
  
   ;;; Rules

   "abox-enumeration"
   "deterministic-expansion3"
   "or-expansion"
   "some-expansion2"
   "feature-expansion"
   "simple-number-restrictions-expansion"
   "meta-constraints"
   "blocking2"
   "model-merging4"
   "abox-saturation"
   "precompletion"
   "core-models"
   
   ;;; Prover

   "alch-prover"   
   "alchf-prover"
   
   "alchn-prover"   
   "alchf-rplus-prover"
   
   ;; "alchfn-rplus-prover"

   ;; "alchi-prover"
   ;; "alchif-prover"
   ;; "alchi-rplus-prover"
   ;; "alchif-rplus-prover"
   ;; "alchifn-rplus-prover"

   ;; "alci-ra-minus-prover"
   ;; "alci-ra-jepd-prover"
   
   ;;; Interface

   "interface4"
   "tbox9"   
   "roles"
   "models"
   
   "abox-queries3"
   "krss"   
   "file-interface"
   "statistics"

   ;; "ddl"
   
   #+:clsql "db-abox"
   
   dl-benchmark
   
   nrql
   "midelora-lubm"
   "tester"))


;;;
;;;
;;;


;;; if you have clim, you get some extra functionality, but it is not required: 

(require "clim")

(prover-dev t)

(terpri)

(princ "(in-package :prover)
(sat? (and c d (some r e) (all r (not e))))
(test 1)")


