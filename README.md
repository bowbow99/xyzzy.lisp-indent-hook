lisp-indent-hook

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
フック変数 *lisp-indent-hook* に、特定の場合にインデントを計算する関数を追加します。
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
という状態で、* の位置から得られる周辺の情報は以下のようなもの。
    (("if" 914 5 2)
     ("let" 887 3 2)
     ("defun 860 1 3))

このままでは扱いにくいので、use-sexp-info-accessors と with-places というマクロを定義してあります。

# with-places (place*) object &body body
place に object からデータを取得する関数を指定すると、その関数名（シンボル）をそのデータにローカルに束縛します。
    (with-places (first second third) '(foo bar baz)
      (list third second first))
    => (baz bar foo)

# use-sexp-info-accessors &body body
前述の「周辺のS式の情報」に対する、理解しやすい名前のアクセス関数を labels で定義します。
    (let ((info '("defun" 860 1 3)))
      (use-exp-info-accessors
        (values (symbol-of info)
                (point-of info)
                (column-of info)
                (nth-arg info)))
    => "defun"
    => 860
    => 1
    => 3

INFO: この2つのマクロは editor パッケージ内で定義されているが、export されていない。

