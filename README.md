lisp-mode などでインデントを計算する calc-lisp-indent に hook を追加することで、特定の場合にインデントを変更できるようにするもの。


インストール
===============
netinstaller でインストール後、初期化ファイルにて読み込む。

    (require "lisp-indent-hook")


設定する #1: 付属の設定を使う
===============================
<xyzzy>/site-lisp/lisp-indent-hook/ 以下に付属の設定があるので、それを使う場合は読み込むだけでおｋ。

    (require "lisp-indent-hook/flet-like")


設定する #2: 独自のインデント計算を追加
=========================================
フック変数 \*lisp-indent-hook\* に、特定の場合にインデントを計算する関数を追加します。

    (add-hook '*lisp-indent-hook* 'my-calc-indent)

この関数は

- 引数として周辺のS式の情報が渡されます
- インデントを指定する場合はインデント量（桁数）を返します
- インデントを指定しない場合は nil を返します

周辺のS式の情報 について
-------------------------
インデントを計算する行の行頭であるポイントを包んでいる各S式について

- オペレータ（関数/マクロ名）{string}
- S式の開始位置 {number}: (point) で得られる数字
- オペレータの開始位置の桁数 {number}: (curren-colum) で得られる数字
- インデント対象行は、そのS式の何番目の引数になるか {number}

をリストにまとめたもの。

EXAMPLE:

    (defun example (arg)
      (let (foo bar baz)
        (if (find arg *some-list*)
            *
          )))

という状態で、* の位置から得られる周辺の情報は以下のようなもの。順番は先頭が最も内側のS式になってる。

    (("if" 914 5 2)
     ("let" 887 3 2)
     ("defun" 860 1 3))

このままでは扱いにくいので、use-sexp-info-accessors と with-places というマクロを定義してあります。

### with-places (place*) object &body body
place に object からデータを取得する関数を指定すると、その関数名（シンボル）をそのデータにローカルに束縛します。

    (with-places (first second third) '(foo bar baz)
      (list third second first))
    => (baz bar foo)

### use-sexp-info-accessors &body body
前述の「周辺のS式の情報」に対する、理解しやすい名前のアクセス関数を labels で定義します。

    (let ((info '("defun" 860 1 3)))
      (use-sexp-info-accessors
        (values (symbol-of info)
                (point-of info)
                (column-of info)
                (nth-arg info))))
    => "defun"
    => 860
    => 1
    => 3

### 使い方の例
    (defun my-calc-lisp-indent (info)
      (use-sexp-info-accessors
       (with-places (first second third) info
         (when (and (string= (symbol-of second) "defun")
                    (= (nth-arg second) 2))
           ...))))

INFO: この2つのマクロは editor パッケージ内で定義されているが、export されていない。

License
===========
The MIT License

Copyright (c) 2009 bowbow99

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
