[English](README.md)

# bash-snippets

這是本喵寫的一些可重用的 bash 代碼和工具，它們首要目標是簡單和易用。

如果沒有特別說明，下載單個檔案就能使用，它們沒有任何額外依賴。

```
source dst/strings.sh

if strings_end_with "$s" "$end";then
    echo "yes, '$s' end with '$end'"
fi
```

- [項目佈局](#項目佈局)
- [result](#result)
- [函數聲明](#函數聲明)
- [test.sh](#test)
- [api](document/zh/README.md)

# 項目佈局

- **dst** 此檔案夾中包含了所有可重用代碼庫
- **example** 此檔案夾中包含了一些使用示例
- **src** 一些代碼由 src 中的源碼生成而來
- **generate.sh** 執行這個腳本重新生成由代碼創建的檔案
- **test.sh** 一個 bash 單元測試工具

# result

bash 函數無法返回整數之外的內容，解決方案是可以使用全局變量進行返回，也使用 echo
返回字符串。本庫採用全局變量的方式爲函數返回內容(echo
不能返回一个数组，函数失败时也難以返回錯誤原因)

1. 如果函數發生錯誤，會將錯誤的描述字符串設置到變量
   `result_errno=...`，之後函數返回錯誤代碼 `return errno`
2. 如果函數存在返回值，則將返回內容設置到變量 `result=...`
3. 如果在 bash 中指定了 '-e' 選項，大部分函數會在出錯時自動執行
   `echo "$result_errno"` 之後再返回 `return errno`

> rule 3 是爲了在 bash 指定
> '-e'參數時可以自動打印錯誤信息。但是對於判別式函數通常會配合 if
> 使用它們不會自動將錯誤輸出到 stdout

```
# return value
if ! get_value; then
  echo "errno: $?"
  exit 1
fi
echo "value=$result"


# return array
if ! get_array; then
  echo "errno: $?"
  exit 1
fi
i=0
for val in "${result[@]}";do
    echo "value[$i] = $val"
    i=$((i+1))
done
```

# 函數聲明

好的函數聲明能夠告訴人類應該如何使用，以及它會返回什麼。本喵提供了類似
typescript
格式的函数声明。了解如何看懂聲明是掌握使用函數的最簡潔與快速的方式，下面有一些例子：

```
function strings_split(s: string, separators: string): []string
```

> strings_split 函數接受兩個位置參數，一個字符串 s 和 分隔標記
> separators，函數將 s 分隔後返回一個字符串數組。

```
(separator: string, ...s: []string): string
```

> 上面的聲明省略了函數名，這種寫法通常在源代碼的函數上方，因爲源碼中已經存在了名稱，此外
> ...s 表示不定長參數

```
(): errno
```

> errno 返回值表示這個函數是一個判別式，通常只是爲了和 if
> 一起使用，它沒有返回內容

```
() (id: number, errno)
```

> 上面函數返回一個數字到 result 變量，同時因爲存在 errno
> 所以這個函數可能會出現錯誤 `return errno`

# test

只有經過測試的代碼才能放心使用，特別是 bash
腳本通常用於系統管理，如果未經測試很可能直接導致系統崩潰。

test.sh 是本喵爲 bash寫的一個單元測試工具，它會查找 bash 源碼中以 test_
爲前綴的函數並執行，同時可以打印一些測試相關的信息。dst 檔案夾下存在很多以
_test.sh
爲後綴的檔案，你可以參考它們來寫單元測試代碼，[dst/assert.sh](document/zh/assert.md)
提供了一些簡化測試代碼的函數。

查看使用說明：

```
./test.sh -h
```

測試指定檔案：

```
./test.sh dst/strings_test.sh dst/path_test.sh
```

測試檔案夾下所有測試檔案(*_test.sh)：

```
./test.sh
./test.sh -d dst
```
