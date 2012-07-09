#!/var/lib/bin/csi -s
(use posix)

; return a function that upon each invocation returns the next
; letter of the alphabet, #f when exhausted
(define letter-seq
  (lambda ()
	(let ((letters (string->list "abcdefghijklmnopqrstuvwxyz")))
	  (lambda ()
		(if (null? letters)
		  #f
		  (let ((h (car letters)))
			(set! letters (cdr letters))
			h))))))

; map a word into a "pattern" highlighting repeated letters
; e.g. "gentoo"  -> "abcdee"
;      "level"   -> "abcba"
;      "pattern" -> "abccdef"
;      "ain't"   -> "abc'd"
;      "I'm"     -> "a'b"
(define word->pattern
  (lambda (w)
	(list->string
	  (let ((next-letter (letter-seq)))
		(let loop ((chars (string->list (string-downcase w)))
				   (letters '()))
		  (if (null? chars)
			'()
			(let ((h (car chars)))
			  (cond
				((not (char-alphabetic? h))
				 (cons h (loop (cdr chars) letters)))
				((assq h letters)
				 => (lambda (r)
					  (cons (cdr r) (loop (cdr chars) letters))))
				(else
				  (let ((n (next-letter)))
					(cons n (loop (cdr chars)
								  (cons (cons h n) letters)))))))))))))

;Read a dictionary file and map each word to its pattern
;Build up an alist keyed on these patterns
(define prepare-dictionary
  (lambda (filename)
	(let ((alist '())
		  (size (file-size filename)))
	  (with-input-from-file
		filename
		(lambda ()
		  (let loop ((word (read-line)) (lines 1))
			(and (= 0 (remainder lines 500))
				 (printf "\r~a/~a"
						 (file-position (current-input-port)) size)
				 (flush-output))
			(if (eof-object? word)
			  alist
			  (let ((pattern (word->pattern word)))
				(cond
				  ((assoc pattern alist)
				   => (lambda (match)
						(append! match (list word))
						(loop (read-line) (add1 lines))))
				  (else
					(set! alist (append alist (list (list pattern word))))
					(loop (read-line) (add1 lines))))))))))))

; vim:set ft=scheme:
