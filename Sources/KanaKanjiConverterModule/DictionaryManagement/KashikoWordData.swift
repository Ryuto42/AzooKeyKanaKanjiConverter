// Generated from Kashiko IME's english.tsv, loanwords.tsv and counters.tsv. Do not edit by hand.

enum KashikoWordData {
    /// English words recognized inside roman-to-kana input: lowercase word → (is a proper noun, usual spelling).
    static let englishWords: [String: (proper: Bool, spelling: String?)] = {
        var result: [String: (proper: Bool, spelling: String?)] = [:]
        for line in englishTSV.split(separator: "\n") {
            let columns = line.split(separator: "\t", omittingEmptySubsequences: false)
            result[String(columns[0])] = (columns[1] == "p", columns[2].isEmpty ? nil : String(columns[2]))
        }
        return result
    }()

    /// Katakana loanwords usually written in Latin script: katakana → spelling.
    static let loanwords: [String: String] = {
        var result: [String: String] = [:]
        for line in loanwordTSV.split(separator: "\n") {
            let columns = line.split(separator: "\t")
            result[String(columns[0])] = String(columns[1])
        }
        return result
    }()

    /// Counters (助数詞): katakana reading → surfaces, most usual first.
    static let counters: [String: [String]] = {
        var result: [String: [String]] = [:]
        for line in counterTSV.split(separator: "\n") {
            let columns = line.split(separator: "\t")
            result[String(columns[0])] = columns.dropFirst().map(String.init)
        }
        return result
    }()

    private static let englishTSV = """
about	c	
access	c	
accessibility	c	
account	c	
action	c	
adapter	c	
add	c	
admin	c	
adobe	p	Adobe
after	c	
again	c	
agenda	c	
agent	c	
aggregation	c	
airbnb	p	Airbnb
alert	c	
alias	c	
alignment	c	
all	c	
alpha	c	
also	c	
always	c	
amazon	p	Amazon
and	c	
android	p	Android
animation	c	
annotation	c	
annotator	c	
answer	c	
any	c	
app	c	
apple	p	Apple
apply	c	
approve	c	
architecture	c	
archive	c	
are	c	
array	c	
asana	p	Asana
ask	c	
assertion	c	
assign	c	
async	c	
attention	c	
attribute	c	
authentication	c	
authorization	c	
autoscale	c	
await	c	
aws	p	AWS
azure	p	Azure
back	c	
backend	c	
backlog	c	
backup	c	
bad	c	
baseline	c	
batch	c	
because	c	
before	c	
benchmark	c	
best	c	
beta	c	
better	c	
big	c	
binary	c	
bing	p	Bing
bit	c	
bitbucket	p	Bitbucket
blocker	c	
bluesky	p	Bluesky
body	c	
boilerplate	c	
bold	c	
book	c	
boolean	c	
both	c	
bottleneck	c	
branch	c	
break	c	
breakpoint	c	
broadcast	c	
browser	c	
bucket	c	
budget	c	
buffer	c	
bug	c	
build	c	
bundle	c	
bundler	c	
but	c	
button	c	
by	c	
byte	c	
cache	c	
call	c	
callback	c	
can	c	
cancel	c	
capacity	c	
chatgpt	p	ChatGPT
check	c	
checkout	c	
chrome	p	Chrome
chromium	p	Chromium
churn	c	
class	c	
claude	p	Claude
clean	c	
clear	c	
click	c	
client	c	
clone	c	
close	c	
closure	c	
cloud	c	
cloudflare	p	Cloudflare
cluster	c	
code	c	
codex	p	Codex
color	c	
column	c	
command	c	
comment	c	
commit	c	
compile	c	
compiler	c	
component	c	
config	c	
conflict	c	
connection	c	
console	c	
const	c	
constructor	c	
contact	c	
container	c	
content	c	
context	c	
continue	c	
conversion	c	
cookie	c	
copilot	p	Copilot
copy	c	
coroutine	c	
cost	c	
could	c	
count	c	
coverage	c	
create	c	
credential	c	
css	c	CSS
current	c	
cursor	p	Cursor
customer	c	
dashboard	c	
data	c	
database	c	
dataset	c	
date	c	
day	c	
deadline	c	
deadlock	c	
debug	c	
debugger	c	
decode	c	
decorator	c	
default	c	
delete	c	
deploy	c	
deployment	c	
deprecate	c	
deserialize	c	
design	c	
destructor	c	
dev	c	
did	c	
diff	c	
directory	c	
discord	p	Discord
display	c	
do	c	
docker	p	Docker
docs	c	
document	c	
documentation	c	
does	c	
domain	c	
done	c	
downgrade	c	
download	c	
downtime	c	
draft	c	
driver	c	
dropbox	p	Dropbox
dump	c	
edge	p	Edge
edit	c	
editor	c	
else	c	
email	c	
embedding	c	
empty	c	
enable	c	
encode	c	
encryption	c	
end	c	
endian	c	
endpoint	c	
engagement	c	
engine	c	
enter	c	
entry	c	
enum	c	
env	c	
epoch	c	
error	c	
escalation	c	
escape	c	
event	c	
every	c	
example	c	
excel	p	Excel
except	c	
export	c	
facebook	p	Facebook
factory	c	
false	c	
feature	c	
feedback	c	
fetch	c	
field	c	
figma	p	Figma
file	c	
filter	c	
find	c	
firebase	p	Firebase
firefox	p	Firefox
firewall	c	
first	c	
fix	c	
fixture	c	
flag	c	
float	c	
folder	c	
follow	c	
font	c	
for	c	
fork	c	
format	c	
formatter	c	
framework	c	
freemium	c	
from	c	
frontend	c	
function	c	
gateway	c	
gemini	p	Gemini
generics	c	
get	c	
git	p	Git
github	p	GitHub
gitlab	p	GitLab
global	c	
gmail	p	Gmail
go	c	
good	c	
google	p	Google
gradient	c	
graph	c	
great	c	
group	c	
handshake	c	
has	c	
hash	c	
have	c	
he	c	
header	c	
heap	c	
hello	c	
help	c	
her	c	
here	c	
heroku	p	Heroku
him	c	
his	c	
home	c	
hook	c	
host	c	
how	c	
html	c	HTML
http	c	HTTP
https	c	HTTPS
hyperparameter	c	
icon	c	
id	c	
if	c	
image	c	
immutable	c	
import	c	
in	c	
index	c	
inference	c	
info	c	
infrastructure	c	
injection	c	
input	c	
insert	c	
instagram	p	Instagram
install	c	
instance	c	
int	c	
intel	p	Intel
interface	c	
interpreter	c	
into	c	
ipad	p	iPad
iphone	p	iPhone
is	c	
issue	c	
it	c	
item	c	
iterator	c	
its	c	
java	p	Java
javascript	p	JavaScript
jira	p	Jira
job	c	
join	c	
json	c	JSON
just	c	
kanban	c	
key	c	
know	c	
kotlin	p	Kotlin
kubernetes	p	Kubernetes
label	c	
lambda	c	
last	c	
latency	c	
launch	c	
layer	c	
layout	c	
level	c	
library	c	
license	c	
like	c	
line	c	
link	c	
linkedin	p	LinkedIn
lint	c	
linter	c	
linux	p	Linux
list	c	
local	c	
lock	c	
log	c	
logging	c	
login	c	
logout	c	
look	c	
loop	c	
loss	c	
love	c	
macbook	p	MacBook
macos	p	macOS
macro	c	
main	c	
make	c	
manual	c	
map	c	
markdown	c	
match	c	
me	c	
meeting	c	
memo	c	
memory	c	
menu	c	
merge	c	
message	c	
method	c	
metrics	c	
microsoft	p	Microsoft
middleware	c	
migrate	c	
migration	c	
milestone	c	
mixin	c	
mock	c	
modal	c	
mode	c	
model	c	
module	c	
monitoring	c	
more	c	
most	c	
mount	c	
much	c	
must	c	
mutable	c	
my	c	
mysql	p	MySQL
name	c	
navigation	c	
need	c	
netflix	p	Netflix
network	c	
new	c	
news	c	
next	c	
nextjs	p	Next.js
nginx	p	nginx
nice	c	
node	c	
nodejs	p	Node.js
not	c	
note	c	
notion	p	Notion
now	c	
npm	p	npm
null	c	
number	c	
nvidia	p	NVIDIA
object	c	
of	c	
off	c	
ok	c	
okay	c	
old	c	
on	c	
onboarding	c	
one	c	
only	c	
open	c	
openai	p	OpenAI
optimizer	c	
option	c	
or	c	
orchestration	c	
order	c	
other	c	
our	c	
out	c	
outlook	p	Outlook
output	c	
over	c	
overfitting	c	
overflow	c	
overload	c	
override	c	
owner	c	
package	c	
page	c	
panel	c	
param	c	
parameter	c	
parse	c	
parser	c	
partition	c	
passphrase	c	
password	c	
patch	c	
path	c	
payload	c	
paypal	p	PayPal
performance	c	
permission	c	
persona	c	
php	p	PHP
pipe	c	
pipeline	c	
placeholder	c	
please	c	
plugin	c	
pod	c	
point	c	
pointer	c	
polling	c	
port	c	
post	c	
postgres	p	Postgres
postgresql	p	PostgreSQL
postmortem	c	
powerpoint	p	PowerPoint
print	c	
priority	c	
privacy	c	
private	c	
process	c	
product	c	
production	c	
profile	c	
profiling	c	
progress	c	
project	c	
promise	c	
prompt	c	
property	c	
protocol	c	
provisioning	c	
proxy	c	
public	c	
pull	c	
push	c	
python	p	Python
quality	c	
query	c	
queue	c	
quick	c	
react	p	React
read	c	
readme	c	README
ready	c	
really	c	
rebase	c	
record	c	
redirect	c	
redis	p	Redis
refactor	c	
refactoring	c	
reference	c	
regression	c	
release	c	
remote	c	
remove	c	
rendering	c	
replica	c	
reply	c	
repo	c	
report	c	
repository	c	
request	c	
requirement	c	
reranking	c	
reset	c	
resource	c	
response	c	
responsive	c	
rest	c	
restore	c	
result	c	
retention	c	
retrospective	c	
retry	c	
return	c	
review	c	
right	c	
risk	c	
roadmap	c	
role	c	
rollback	c	
root	c	
route	c	
router	c	
routing	c	
row	c	
run	c	
runner	c	
runtime	c	
rust	p	Rust
safari	p	Safari
salesforce	p	Salesforce
salt	c	
sanitize	c	
save	c	
scaling	c	
schedule	c	
schema	c	
scope	c	
screen	c	
script	c	
scrum	c	
search	c	
secret	c	
security	c	
see	c	
seed	c	
segment	c	
select	c	
send	c	
serialize	c	
server	c	
service	c	
session	c	
set	c	
setting	c	
setup	c	
shard	c	
she	c	
shell	c	
should	c	
show	c	
sign	c	
signature	c	
singleton	c	
size	c	
skeleton	c	
skill	c	
skip	c	
slack	p	Slack
snippet	c	
so	c	
socket	c	
some	c	
sort	c	
source	c	
spec	c	
spotify	p	Spotify
sprint	c	
sql	p	SQL
stack	c	
staging	c	
stakeholder	c	
start	c	
stash	c	
state	c	
status	c	
step	c	
stop	c	
storage	c	
store	c	
streaming	c	
string	c	
stripe	p	Stripe
struct	c	
stub	c	
style	c	
subcommand	c	
subdomain	c	
submit	c	
subscription	c	
subtask	c	
support	c	
swift	p	Swift
switch	c	
sync	c	
system	c	
table	c	
tag	c	
target	c	
task	c	
team	c	
teams	p	Teams
template	c	
tensor	c	
terminal	c	
test	c	
text	c	
than	c	
thank	c	
thanks	c	
that	c	
the	c	
their	c	
them	c	
theme	c	
then	c	
there	c	
these	c	
they	c	
thing	c	
think	c	
this	c	
thread	c	
throttling	c	
throughput	c	
ticket	c	
tiktok	p	TikTok
time	c	
timeout	c	
title	c	
to	c	
today	c	
todo	c	TODO
token	c	
tokenization	c	
tokenizer	c	
tool	c	
tooltip	c	
trace	c	
training	c	
trait	c	
transaction	c	
transformer	c	
transition	c	
transpile	c	
trial	c	
true	c	
try	c	
twitter	p	Twitter
type	c	
typescript	p	TypeScript
ubuntu	p	Ubuntu
underflow	c	
undo	c	
uninstall	c	
unity	p	Unity
update	c	
upgrade	c	
upload	c	
uptime	c	
url	c	URL
use	c	
user	c	
validation	c	
value	c	
var	c	
vector	c	
vercel	p	Vercel
version	c	
very	c	
view	c	
viewport	c	
vim	p	Vim
vscode	p	VS Code
want	c	
was	c	
watch	c	
we	c	
web	c	
webhook	c	
well	c	
were	c	
what	c	
whatsapp	p	WhatsApp
when	c	
where	c	
which	c	
while	c	
who	c	
why	c	
widget	c	
wildcard	c	
will	c	
window	c	
windows	p	Windows
with	c	
word	c	
wordpress	p	WordPress
work	c	
workaround	c	
workflow	c	
workshop	c	
world	c	
would	c	
wrapper	c	
write	c	
xcode	p	Xcode
xml	c	XML
yaml	c	YAML
year	c	
yes	c	
yet	c	
you	c	
your	c	
youtube	p	YouTube
zoom	p	Zoom
"""

    private static let loanwordTSV = """
リポジトリ	repository
レポジトリ	repository
コミット	commit
ブランチ	branch
マージ	merge
リベース	rebase
プルリクエスト	pull request
プルリク	pull request
クローン	clone
フォーク	fork
コンフリクト	conflict
スタッシュ	stash
タグ	tag
イシュー	issue
チェックアウト	checkout
リモート	remote
ローカル	local
プッシュ	push
プル	pull
ディフ	diff
パッチ	patch
リリース	release
マイルストーン	milestone
ビルド	build
デプロイ	deploy
デプロイメント	deployment
コンパイル	compile
リンク	link
パイプライン	pipeline
ワークフロー	workflow
ジョブ	job
ランナー	runner
ステージング	staging
プロダクション	production
ロールバック	rollback
オーケストレーション	orchestration
コンテナ	container
イメージ	image
クラスタ	cluster
クラスター	cluster
ノード	node
ポッド	pod
レプリカ	replica
スケーリング	scaling
オートスケール	autoscale
プロビジョニング	provisioning
インフラ	infrastructure
インフラストラクチャ	infrastructure
モニタリング	monitoring
メトリクス	metrics
トレース	trace
アラート	alert
ダッシュボード	dashboard
ログ	log
ロギング	logging
ヘルスチェック	health check
アップタイム	uptime
ダウンタイム	downtime
レイテンシ	latency
スループット	throughput
ボトルネック	bottleneck
テンプレート	template
フレームワーク	framework
ライブラリ	library
パッケージ	package
モジュール	module
コンポーネント	component
インターフェース	interface
インターフェイス	interface
クラス	class
メソッド	method
プロパティ	property
フィールド	field
パラメータ	parameter
パラメーター	parameter
アトリビュート	attribute
コンストラクタ	constructor
デストラクタ	destructor
オーバーライド	override
オーバーロード	overload
ジェネリクス	generics
トレイト	trait
ミックスイン	mixin
デコレータ	decorator
アノテーション	annotation
マクロ	macro
イテレータ	iterator
クロージャ	closure
ラムダ	lambda
コールバック	callback
プロミス	promise
フック	hook
ミドルウェア	middleware
プラグイン	plugin
アダプタ	adapter
ラッパー	wrapper
ファクトリ	factory
シングルトン	singleton
リファクタリング	refactoring
リファクタ	refactor
デザインパターン	design pattern
アーキテクチャ	architecture
ボイラープレート	boilerplate
スニペット	snippet
スケルトン	skeleton
スタブ	stub
モック	mock
フィクスチャ	fixture
データベース	database
テーブル	table
カラム	column
レコード	record
ロー	row
クエリ	query
インデックス	index
スキーマ	schema
マイグレーション	migration
トランザクション	transaction
ロック	lock
コネクション	connection
コネクションプール	connection pool
キャッシュ	cache
バッファ	buffer
ストレージ	storage
バケット	bucket
パーティション	partition
シャード	shard
バックアップ	backup
リストア	restore
ダンプ	dump
シード	seed
プライマリキー	primary key
フォーリンキー	foreign key
ジョイン	join
アグリゲーション	aggregation
インメモリ	in-memory
サーバー	server
サーバ	server
クライアント	client
プロトコル	protocol
エンドポイント	endpoint
リクエスト	request
レスポンス	response
ヘッダー	header
ヘッダ	header
ボディ	body
ペイロード	payload
ステータスコード	status code
ソケット	socket
ポート	port
ホスト	host
ドメイン	domain
サブドメイン	subdomain
ゲートウェイ	gateway
プロキシ	proxy
リバースプロキシ	reverse proxy
ロードバランサ	load balancer
ファイアウォール	firewall
タイムアウト	timeout
リトライ	retry
スロットリング	throttling
レートリミット	rate limit
ウェブフック	webhook
ストリーミング	streaming
ポーリング	polling
ハンドシェイク	handshake
ブロードキャスト	broadcast
バンドル	bundle
ペイロードサイズ	payload size
セキュリティ	security
プライバシー	privacy
オーセンティケーション	authentication
オーソライゼーション	authorization
アカウント	account
パスワード	password
パスフレーズ	passphrase
トークン	token
セッション	session
クッキー	cookie
クレデンシャル	credential
シークレット	secret
ハッシュ	hash
ソルト	salt
エンクリプション	encryption
サイン	sign
シグネチャ	signature
サニタイズ	sanitize
バリデーション	validation
エスケープ	escape
インジェクション	injection
パーミッション	permission
ロール	role
スコープ	scope
ログイン	login
ログアウト	logout
サインイン	sign in
サインアウト	sign out
サインアップ	sign up
ワンタイムパスワード	one-time password
ツーファクタ	two-factor
プロセス	process
スレッド	thread
コルーチン	coroutine
スタック	stack
キュー	queue
ヒープ	heap
ポインタ	pointer
リファレンス	reference
インスタンス	instance
オブジェクト	object
ステート	state
コンテキスト	context
ミュータブル	mutable
イミュータブル	immutable
シリアライズ	serialize
デシリアライズ	deserialize
エンコード	encode
デコード	decode
パース	parse
パーサ	parser
トークナイザ	tokenizer
コンパイラ	compiler
インタプリタ	interpreter
ランタイム	runtime
ガベージコレクション	garbage collection
メモリリーク	memory leak
セグメンテーションフォルト	segmentation fault
デッドロック	deadlock
レースコンディション	race condition
オーバーフロー	overflow
アンダーフロー	underflow
バイナリ	binary
バイト	byte
ビット	bit
エンディアン	endian
アライメント	alignment
レンダリング	rendering
レイアウト	layout
スタイル	style
テーマ	theme
ダークモード	dark mode
ルーティング	routing
ルーター	router
ナビゲーション	navigation
モーダル	modal
ツールチップ	tooltip
プレースホルダ	placeholder
アニメーション	animation
トランジション	transition
レスポンシブ	responsive
ビューポート	viewport
アクセシビリティ	accessibility
バンドラ	bundler
トランスパイル	transpile
ホットリロード	hot reload
サーバーサイドレンダリング	server-side rendering
テスト	test
ユニットテスト	unit test
インテグレーションテスト	integration test
リグレッション	regression
カバレッジ	coverage
アサーション	assertion
デバッグ	debug
デバッガ	debugger
ブレークポイント	breakpoint
スタックトレース	stack trace
リント	lint
リンター	linter
フォーマッタ	formatter
ベンチマーク	benchmark
プロファイリング	profiling
バグ	bug
フィックス	fix
ワークアラウンド	workaround
エッジケース	edge case
ハッピーパス	happy path
コマンド	command
オプション	option
フラグ	flag
サブコマンド	subcommand
スクリプト	script
シェル	shell
ターミナル	terminal
コンソール	console
ディレクトリ	directory
ファイル	file
パス	path
シンボリックリンク	symbolic link
アーカイブ	archive
エクスポート	export
インポート	import
インストール	install
アンインストール	uninstall
アップデート	update
アップグレード	upgrade
ダウングレード	downgrade
ダウンロード	download
アップロード	upload
マウント	mount
プロンプト	prompt
エイリアス	alias
リダイレクト	redirect
パイプ	pipe
ワイルドカード	wildcard
リポジトリミラー	repository mirror
モデル	model
トレーニング	training
ファインチューニング	fine-tuning
インファレンス	inference
トークナイゼーション	tokenization
エンベディング	embedding
ベクトル	vector
テンソル	tensor
レイヤー	layer
ニューラルネットワーク	neural network
トランスフォーマー	transformer
アテンション	attention
バッチ	batch
エポック	epoch
ロス	loss
グラディエント	gradient
オプティマイザ	optimizer
オーバーフィッティング	overfitting
データセット	dataset
ラベル	label
アノテーター	annotator
パイプライン処理	pipeline
ハイパーパラメータ	hyperparameter
ベースライン	baseline
リランキング	reranking
ビームサーチ	beam search
プロジェクト	project
タスク	task
サブタスク	subtask
チケット	ticket
バックログ	backlog
スプリント	sprint
スクラム	scrum
カンバン	kanban
マイルストン	milestone
デッドライン	deadline
スケジュール	schedule
ミーティング	meeting
アジェンダ	agenda
フィードバック	feedback
レビュー	review
ドキュメント	document
ドキュメンテーション	documentation
マニュアル	manual
スペック	spec
リクワイアメント	requirement
ロードマップ	roadmap
ステークホルダー	stakeholder
オーナー	owner
アサイン	assign
プライオリティ	priority
ステータス	status
プログレス	progress
ブロッカー	blocker
リスク	risk
コスト	cost
バジェット	budget
リソース	resource
キャパシティ	capacity
パフォーマンス	performance
クオリティ	quality
スコープクリープ	scope creep
オンボーディング	onboarding
ワークショップ	workshop
レトロスペクティブ	retrospective
ポストモーテム	postmortem
プロダクト	product
サービス	service
フィーチャー	feature
ユースケース	use case
ユーザー	user
ユーザ	user
カスタマー	customer
ペルソナ	persona
セグメント	segment
ターゲット	target
コンバージョン	conversion
リテンション	retention
チャーン	churn
エンゲージメント	engagement
サブスクリプション	subscription
ライセンス	license
トライアル	trial
フリーミアム	freemium
ローンチ	launch
ベータ	beta
アルファ	alpha
マイグレート	migrate
デプリケート	deprecate
サポート	support
エスカレーション	escalation
サービスレベル	service level
"""

    private static let counterTSV = """
ネン	年
ネンセイ	年生
ガツ	月
カゲツ	か月	ヶ月
ニチ	日
ジツ	日
ジ	時
ジカン	時間
フン	分
プン	分
ビョウ	秒
シュウ	週
シュウカン	週間
ハク	泊
パク	泊
キ	期	機
ガッキ	学期
ダイ	台	代
セイキ	世紀
カイ	階	回
ガイ	階
ゲン	限	軒
コマ	コマ
ジゲン	時限
バン	番
バンメ	番目
バンセン	番線
イ	位
ゴウ	号
ゴウシツ	号室
シツ	室
セキ	席
レツ	列
ギョウ	行
ページ	ページ
ショウ	章
セツ	節
コウ	項
カジョウ	箇条
チョウメ	丁目
ニン	人
メイ	名
リ	人
タリ	人
コ	個
ツ	つ
ホン	本
ボン	本
ポン	本
マイ	枚
サツ	冊
キャク	脚	客
ヒキ	匹
ビキ	匹
ピキ	匹
トウ	頭
ワ	羽
バ	羽
パ	羽
ハイ	杯
バイ	倍	杯
パイ	杯
ソク	足
ゾク	足
チャク	着
ケン	件	軒
クミ	組
グミ	組
タバ	束
ツブ	粒
テキ	滴
ミン	名
モジ	文字
ケタ	桁
シュルイ	種類
カショ	箇所	か所
カコク	か国
ダンカイ	段階
ジカンメ	時間目
ド	度
ワリ	割
パーセント	パーセント
プロ	プロ
エン	円
セン	銭
ドル	ドル
キロ	キロ
グラム	グラム
キログラム	キログラム
トン	トン
メートル	メートル
キロメートル	キロメートル
センチ	センチ
ミリ	ミリ
リットル	リットル
ヘイベイ	平米
ツボ	坪
サイ	歳	才
ニンブン	人分
ニンマエ	人前
"""
}
