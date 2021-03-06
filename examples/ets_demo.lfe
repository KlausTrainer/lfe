;; Copyright (c) 2011 Robert Virding. All rights reserved.
;;
;; Redistribution and use in source and binary forms, with or without
;; modification, are permitted provided that the following conditions
;; are met:
;;
;; 1. Redistributions of source code must retain the above copyright
;;    notice, this list of conditions and the following disclaimer.
;; 2. Redistributions in binary form must reproduce the above copyright
;;    notice, this list of conditions and the following disclaimer in the
;;    documentation and/or other materials provided with the distribution.
;;
;; THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
;; "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
;; LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
;; FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
;; COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
;; INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
;; BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
;; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
;; CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
;; LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
;; ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
;; POSSIBILITY OF SUCH DAMAGE.

;; File    : ets_demo.lfe
;; Author  : Robert Virding
;; Purpose : A simple ETS demo file for LFE.

;; This file contains a simple demo of using LFE to access ETS tables.
;; It shows how to use the emp-XXXX macro (ETS match pattern) together
;; with ets:match/match_object and match specifications with
;; ets:select.

(defmodule ets_demo
  (export (new 0) (by_place 2) (by_place_ms 2) (not_painter 2)))

;; Define a simple person record to work on.
(defrecord person name place job)

;; Create an initialse the ets table.
(defun new ()
  (let ((db (: ets new 'ets_demo '(#(keypos 2) set))))
    (let ((people '(
		    ;; First some people in London.
		    #(fred london waiter)
		    #(bert london waiter)
		    #(john london painter)
		    #(paul london driver)
		    ;; Now some in Paris.
		    #(jean paris waiter)
		    #(gerard paris driver)
		    #(claude paris painter)
		    #(yves paris waiter)
		    ;; And some in Rome.
		    #(roberto rome waiter)
		    #(guiseppe rome driver)
		    #(paulo rome painter)
		    ;; And some in Berlin.
		    #(fritz berlin painter)
		    #(kurt berlin driver)
		    #(hans berlin waiter)
		    #(franz berlin waiter)
		    )))
      (: lists foreach (match-lambda
			 ([(tuple n p j)]
			  (: ets insert db (make-person name n place p job j))))
	 people))
    db))				;Return the table

;; Match records by place using match, match_object and the emp-XXXX macro.
(defun by_place (db place)
  (let ((s1 (: ets match db (emp-person name '$1 place place job '$2)))
	(s2 (: ets match_object db (emp-person place place))))
    (tuple s1 s2)))

;; Use match specifications to match records
(defun by_place_ms (db place)
  (: ets select db (match-spec ([(match-person name n place p job j)]
				(when (=:= place p))
				(list 'p n j)))))

(defun not_painter (db place)
  (: ets select db (match-spec ([(match-person name n place p job j)]
				(when (=:= place p) (=/= j 'painter))
				(list 'p n j)))))
