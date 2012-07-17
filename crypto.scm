#!/var/lib/bin/csi -s
(use posix)

; return a function that upon each invocation returns the next
; letter of the alphabet, #f when exhausted
(define (letter-seq)
	(let ((letters (string->list "abcdefghijklmnopqrstuvwxyz")))
	  (lambda ()
		(if (null? letters)
		  #f
		  (let ((h (car letters)))
			(set! letters (cdr letters))
			h)))))

; map a word into a "pattern" highlighting repeated letters
; e.g. "gentoo"  -> "abcdee"
;      "level"   -> "abcba"
;      "pattern" -> "abccdef"
;      "ain't"   -> "abc'd"
;      "I'm"     -> "a'b"
(define (word->pattern w)
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
								  (cons (cons h n) letters))))))))))))

;Read a dictionary file and map each word to its pattern
;Build up a hash-table keyed on these patterns
(define (prepare-dictionary filename)
	(let ((dict (make-hash-table))
		  (size (file-size filename)))
	  (with-input-from-file
		filename
		(lambda ()
		  (let loop ((word (read-line)) (lines 1))
			(and (= 0 (remainder lines 500))
				 (printf "\r~a/~a"
						 (file-position (current-input-port)) size)
				 (flush-output))
			(cond
			  ((eof-object? word)
			   (newline)
			   dict)
			  (else
				(let ((pattern (word->pattern word)))
				  (cond
					((hash-table-exists? dict pattern)
					 (hash-table-set!
					   dict pattern
					   (cons word (hash-table-ref dict pattern)))
					 (loop (read-line) (add1 lines)))
					(else
					  (hash-table-set!
						dict pattern (list word))
					  (loop (read-line) (add1 lines))))))))))))

; vim:set ft=scheme:
