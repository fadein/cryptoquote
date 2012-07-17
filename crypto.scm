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
			(and (= 0 (remainder lines 5000))
				 (let* ((position (file-position (current-input-port)))
						(percent (* 100 (/ position size))))
				   (printf "\r~a" (fmt #f "Preparing dictionary " (num percent 10 2) "%"))
				   (flush-output)))
			(cond
			  ((eof-object? word)
			   (print "\rPreparing dictionary 100.00%")
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

(define char-set:crypto
  (string->char-set "abcdefghijklmnopqrstuvwxyz'"))

(define (quote->patterns quot)
  (map (lambda (s) (word->pattern s))
	   (string-tokenize (string-downcase quot) char-set:crypto)))

; cryptoquote strategies:
; http://www.cryptoquote.org/strategies.html

; more ideas:
; http://www.gtoal.com/wordgames/cryptograms.html
(define sample-quote
  "Ubty lzm vz dy xzq j kzg dyrtqadtu, D rbdyn j vzzs rbdyv rz jen de dx rbtl tatq oqtee pbjqvte.")

(define sample-solution
  "When you go in for a job interview, I think a good thing to ask is if they ever press charges.")




; vim:set ft=scheme:
