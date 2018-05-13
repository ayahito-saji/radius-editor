class Radius
  require File.dirname(__FILE__) + '/radius_parser'
  require 'pp'

  attr_accessor(:code)
  def analysis
    parser = RadiusParser.new
    @structure = parser.parse(@code)
    p @structure
  end
  def process
    @output_data = ""
    @null_obj = [:INSTANCE, nil, nil]
    # 基本クラスの設定(Object, Number, String, Boolean, List, Hash)
    @object_class = [:CLASS, nil, {
        'new'=> [[:FUNCTION, nil, [:BUILD_IN, 'instance = [:INSTANCE, self_obj, {}];evaluate([:FUNC_CALL, [:VARIABLE, [:SELF], [:IDENTIFIER, "init"]], argv], env, instance);return instance']], :PUBLIC, :STATIC, :CONSTANT],
        'init'=> [[:FUNCTION, nil, nil], :PUBLIC, :STATIC, :CONSTANT]
    }]
    @number_class = [:CLASS, @object_class, {
        'new'=> [[:FUNCTION, nil, [:BUILD_IN, 'instance = [:INSTANCE, self_obj, {}, argv[0][3]];evaluate([:FUNC_CALL, [:VARIABLE, [:SELF], [:IDENTIFIER, "init"]], argv], env, instance);return instance;']], :PUBLIC, :STATIC, :CONSTANT],
        '_add'=> [[:FUNCTION, nil, [:BUILD_IN, 'return [:INSTANCE, @number_class, nil, self_obj[3]+argv[0][3]] if(argv[0][0] == :INSTANCE && argv[0][1] == @number_class);return [:INSTANCE, @string_class, nil, self_obj[3].to_s+argv[0][3]] if(argv[0][0] == :INSTANCE && argv[0][1] == @string_class);']], :PUBLIC, :DYNAMIC, :CONSTANT],
        '_sub'=> [[:FUNCTION, nil, [:BUILD_IN, 'return [:INSTANCE, @number_class, nil, self_obj[3]-argv[0][3]] if(argv[0][0] == :INSTANCE && argv[0][1] == @number_class);']], :PUBLIC, :DYNAMIC, :CONSTANT],
        '_mul'=> [[:FUNCTION, nil, [:BUILD_IN, 'return [:INSTANCE, @number_class, nil, self_obj[3]*argv[0][3]] if(argv[0][0] == :INSTANCE && argv[0][1] == @number_class);']], :PUBLIC, :DYNAMIC, :CONSTANT],
        '_div'=> [[:FUNCTION, nil, [:BUILD_IN, 'return [:INSTANCE, @number_class, nil, self_obj[3].to_f/argv[0][3]] if(argv[0][0] == :INSTANCE && argv[0][1] == @number_class);']], :PUBLIC, :DYNAMIC, :CONSTANT],
        '_mod'=> [[:FUNCTION, nil, [:BUILD_IN, 'return [:INSTANCE, @number_class, nil, self_obj[3]%argv[0][3]] if(argv[0][0] == :INSTANCE && argv[0][1] == @number_class);']], :PUBLIC, :DYNAMIC, :CONSTANT],
        '_eq' => [[:FUNCTION, nil, [:BUILD_IN, 'return [:INSTANCE, @boolean_class, nil, self_obj[3]==argv[0][3]];']], :PUBLIC, :DYNAMIC, :CONSTANT],
        '_neq'=> [[:FUNCTION, nil, [:BUILD_IN, 'return [:INSTANCE, @boolean_class, nil, self_obj[3]!=argv[0][3]];']], :PUBLIC, :DYNAMIC, :CONSTANT],
        '_gt' => [[:FUNCTION, nil, [:BUILD_IN, 'return [:INSTANCE, @boolean_class, nil, self_obj[3]>argv[0][3]] if(argv[0][0] == :INSTANCE && argv[0][1] == @number_class);']], :PUBLIC, :DYNAMIC, :CONSTANT],
        '_lt' => [[:FUNCTION, nil, [:BUILD_IN, 'return [:INSTANCE, @boolean_class, nil, self_obj[3]<argv[0][3]] if(argv[0][0] == :INSTANCE && argv[0][1] == @number_class);']], :PUBLIC, :DYNAMIC, :CONSTANT],
        '_gte'=> [[:FUNCTION, nil, [:BUILD_IN, 'return [:INSTANCE, @boolean_class, nil, self_obj[3]>=argv[0][3]] if(argv[0][0] == :INSTANCE && argv[0][1] == @number_class);']], :PUBLIC, :DYNAMIC, :CONSTANT],
        '_lte'=> [[:FUNCTION, nil, [:BUILD_IN, 'return [:INSTANCE, @boolean_class, nil, self_obj[3]<=argv[0][3]] if(argv[0][0] == :INSTANCE && argv[0][1] == @number_class);']], :PUBLIC, :DYNAMIC, :CONSTANT],
        'toString'=> [[:FUNCTION, nil, [:BUILD_IN, 'return [:INSTANCE, @string_class, nil, self_obj[3].to_s]']], :PUBLIC, :DYNAMIC, :CONSTANT]
    }]
    @string_class = [:CLASS, @object_class, {
        'new'=> [[:FUNCTION, nil, [:BUILD_IN, 'instance = [:INSTANCE, self_obj, {}, argv[0][3]];evaluate([:FUNC_CALL, [:VARIABLE, [:SELF], [:IDENTIFIER, "init"]], argv], env, instance);return instance;']], :PUBLIC, :STATIC, :CONSTANT],
        '_add'=> [[:FUNCTION, nil, [:BUILD_IN, 'other = evaluate([:FUNC_CALL, [:VARIABLE, argv[0], [:IDENTIFIER, "toString"]], []], env, self_obj);return [:INSTANCE, @string_class, nil, self_obj[3]+other[3].to_s];']], :PUBLIC, :DYNAMIC, :CONSTANT],
        'toNumber'=> [[:FUNCTION, nil, [:BUILD_IN, 'return [:INSTANCE, @string_class, nil, self_obj[3].to_f]']], :PUBLIC, :DYNAMIC, :CONSTANT],
        'toString'=> [[:FUNCTION, nil, [:BUILD_IN, 'return [:INSTANCE, @string_class, nil, self_obj[3].to_s]']], :PUBLIC, :DYNAMIC, :CONSTANT]
    }]
    @boolean_class = [:CLASS, @object_class, {
        'new'=> [[:FUNCTION, nil, [:BUILD_IN, 'instance = [:INSTANCE, self_obj, {}, argv[0][3]];evaluate([:FUNC_CALL, [:VARIABLE, [:SELF], [:IDENTIFIER, "init"]], argv], env, instance);return instance;']], :PUBLIC, :STATIC, :CONSTANT],
        '_not'=> [[:FUNCTION, nil, [:BUILD_IN, 'return [:INSTANCE, @boolean_class, nil, !self_obj[3]]']], :PUBLIC, :STATIC, :CONSTANT],
        '_and'=> [[:FUNCTION, nil, [:BUILD_IN, 'return [:INSTANCE, @boolean_class, nil, self_obj[3]&&argv[0][3]]']], :PUBLIC, :STATIC, :CONSTANT],
        '_or' => [[:FUNCTION, nil, [:BUILD_IN, 'return [:INSTANCE, @boolean_class, nil, self_obj[3]||argv[0][3]]']], :PUBLIC, :STATIC, :CONSTANT],
        'toString'=> [[:FUNCTION, nil, [:BUILD_IN, 'return [:INSTANCE, @string_class, nil, self_obj[3].to_s]']], :PUBLIC, :DYNAMIC, :CONSTANT]
    }]
    @list_class = [:CLASS, @object_class, {
        'new'=> [[:FUNCTION, nil, [:BUILD_IN, 'instance = [:INSTANCE, self_obj, {}, argv];evaluate([:FUNC_CALL, [:VARIABLE, [:SELF], [:IDENTIFIER, "init"]], argv], env, instance);return instance;']], :PUBLIC, :STATIC, :CONSTANT],
        '_getat'=> [[:FUNCTION, nil, [:BUILD_IN, 'return self_obj[3][argv[0][3]]']], :PUBLIC, :DYNAMIC, :CONSTANT],
        '_setat'=> [[:FUNCTION, nil, [:BUILD_IN, '(argv[0][3] - self_obj[3].length).times do self_obj[3] << @null_obj end;self_obj[3][argv[0][3]] = argv[1];return argv[1]']], :PUBLIC, :DYNAMIC, :CONSTANT]
    }]
    @hash_class = [:CLASS, @object_class, {
        'new'=> [[:FUNCTION, nil, [:BUILD_IN, 'instance = [:INSTANCE, self_obj, {}, argv[0][3]];evaluate([:FUNC_CALL, [:VARIABLE, [:SELF], [:IDENTIFIER, "init"]], argv], env, instance);return instance;']], :PUBLIC, :STATIC, :CONSTANT],
        '_getat'=> [[:FUNCTION, nil, [:BUILD_IN, 'return self_obj[3][argv[0][3]]']], :PUBLIC, :DYNAMIC, :CONSTANT],
        '_setat'=> [[:FUNCTION, nil, [:BUILD_IN, 'self_obj[3][argv[0][3]] = argv[1];return argv[1]']], :PUBLIC, :DYNAMIC, :CONSTANT]
    }]
    @broke = false
    @returned = false
    env = {
        'print'=> [[:FUNCTION, [[:IDENTIFIER, 'obj']], [:BUILD_IN, '@output_data += (evaluate([:FUNC_CALL, [:VARIABLE, argv[0], [:IDENTIFIER, "toString"]], []], env, self_obj)[3].to_s)+"\n";return @null_obj;']], :PUBLIC, :DYNAMIC, :CONSTANT],
        'input'=> [[:FUNCTION, [], [:BUILD_IN, 'return [:INSTANCE, :STRING, nil, gets.chomp]']], :PUBLIC, :DYNAMIC, :CONSTANT],
        'Object'=> [@object_class, :PUBLIC, :DYNAMIC, :CONSTANT],
        'Number'=> [@number_class, :PUBLIC, :DYNAMIC, :CONSTANT],
        'String'=> [@string_class, :PUBLIC, :DYNAMIC, :CONSTANT],
        'Boolean'=> [@boolean_class, :PUBLIC, :DYNAMIC, :CONSTANT],
        'List'=> [@list_class, :PUBLIC, :DYNAMIC, :CONSTANT],
        'Hash'=> [@hash_class, :PUBLIC, :DYNAMIC, :CONSTANT],
    }
    kernel = [:INSTANCE, nil, {}]
#    puts "Evaluate"
#    puts debug_obj(evaluate(@structure, env, kernel), 0)
#    puts "Env"
#    puts debug_env(env, 0)
    evaluate(@structure, env, kernel)
    return @output_data
  end
  def evaluate(tree, current_env, parent_object)
    if tree.nil?
      return
    end
    case tree[0]
      # 複文
      when :STATEMENTS
        result = [:INSTANCE, :NULL, nil]
        tree[1].each do |statement|
          result = evaluate(statement, current_env, parent_object)
          break if @broke
          return result if @returned
        end
        return result

      when :VARIABLE # 変数にアクセス
        var_name = tree[2][1]
        if tree[1] # 上位のオブジェクトを調べる
          obj = evaluate(tree[1], current_env, parent_object)
          # objには上位のオブジェクトが入っている（すなわち、クラスメソッドやクラス変数を呼ぶ場合はクラス、インスタンスメソッドやインスタンス変数を呼ぶ場合はインスタンスが入っている）
          case obj[0]
            when :CLASS # クラス環境を調べる
              new_env = obj[2]
              new_var = new_env[var_name]
              parent_cls = obj[1]
              while new_var.nil?
                break if parent_cls.nil? || parent_cls[0] != :CLASS
                new_env = parent_cls[2]
                new_var = new_env[var_name]
                parent_cls = parent_cls[1]
              end
              raise("'#{tree[2][1]}'は定義されていない変数です") if new_var.nil?
              new_obj = new_var[0] # new_objには、下位のオブジェクトが入っている
              new_obj = new_obj + [obj] if new_obj[0] == :FUNCTION # 関数オブジェクトならば、クラスをくっつけて返す
              return new_obj
            when :INSTANCE # インスタンス環境を調べる
              new_env = obj[2]
              new_var = (new_env ? new_env[var_name]: nil)
              cls = obj[1]
              while new_var.nil?
                break if cls.nil? || cls[0] != :CLASS
                new_env = cls[2]
                new_var = new_env[var_name]
                cls = cls[1]
              end
              raise("'#{tree[2][1]}'は定義されていない変数です") if new_var.nil?
              new_obj = new_var[0]
              new_obj = new_obj + [obj] if new_obj[0] == :FUNCTION # 関数オブジェクトならば、インスタンスをくっつけて返す
              return new_obj
          end
        else # 現在の環境を調べる
          new_var = current_env[var_name]
          if new_var
            new_obj = new_var[0]
            return new_obj
          else
            if parent_object
              return evaluate([:VARIABLE, [:SELF], tree[2]], current_env, parent_object)
            else
              raise("'#{var_name}'は定義されていない変数です")
            end
          end
        end

      when "=" # 変数に代入
        # 値
        val = evaluate(tree[5], current_env, parent_object)
        # 変数オプション
        opt = [tree[1], tree[2], tree[3]]
        # 保存領域
        address = tree[4]
        case address[0]
          when :ENV # 普通の変数に代入の場合
            if address[1].nil?
              save_env = current_env
              save_key = address[2][1]
              #puts "#{save_key} = #{debug_obj(val, 0)} \n#{debug_env(current_env, 0)}"
            else
              obj = evaluate(address[1], current_env, parent_object)
              save_key = address[2][1]
              if obj[0] == :CLASS && obj[2]
                save_env = obj[2]
              elsif obj[0] == :INSTANCE && obj[2]
                save_env = obj[2]
              else
                raise "#{obj[0]}に変数またはメソッドを代入できません"
              end
            end
            if save_env[save_key] # すでに存在する場合、オプションは変更しない
              save_env[save_key] = save_env[save_key].clone
              raise "定数#{save_key}の値を変更できません" if save_env[save_key][3] == :CONSTANT
              save_env[save_key][0] = val
              save_env[save_key][1] = opt[0] if opt[0]
              save_env[save_key][2] = opt[1] if opt[1]
              save_env[save_key][3] = opt[2] if opt[2]
            else # まだ存在しない場合、オプションまで設定する（初回代入）
              opt[0] ||= :NOTHING
              opt[1] ||= :DYNAMIC
              opt[2] ||= (save_key.upcase != save_key ? :VARIABLE : :CONSTANT)
              save_env[save_key] = [val] + opt
            end
          when :INDEX # 配列またはハッシュに代入の場合
            raise "配列またはハッシュの特定の要素のみを#{opt[0]}にすることはできません。" if opt[0]
            raise "配列またはハッシュの特定の要素のみを#{opt[1]}にすることはできません。" if opt[1]
            raise "配列またはハッシュの特定の要素のみを#{opt[2]}にすることはできません。" if opt[2]
            obj = evaluate(address[1], current_env, parent_object)
            index = evaluate(address[2], current_env, parent_object)
            evaluate([:FUNC_CALL, [:VARIABLE, obj, [:IDENTIFIER, "_setat"]], [index, val]], current_env, parent_object)
        end
        return val

      # 構築子
      when :NUMBER_NEW
        return [:INSTANCE, @number_class, nil, tree[1]]
      when :STRING_NEW
        return [:INSTANCE, @string_class, nil, tree[1]]
      when :BOOLEAN_NEW
        return [:INSTANCE, @boolean_class, nil, tree[1]]
      when :LIST_NEW
        list = []
        tree[1].each do |obj|
          list << evaluate(obj, current_env, parent_object)
        end
        return [:INSTANCE, @list_class, nil, list]
      when :HASH_NEW
        hash = {}
        tree[1].each do |item|
          key = evaluate(item[0], current_env, parent_object)
          value = evaluate(item[1], current_env, parent_object)
          if key[0] == :INSTANCE && key[1] == @number_class
            hash[key[3]] = value
          elsif key[0] == :INSTANCE && key[1] == @string_class
            hash[key[3]] = value
          else
            raise "数字または文字列以外はキーとして登録できません"
          end
        end
        return [:INSTANCE, @hash_class, nil, hash]
      when :NULL_NEW
        return @null_obj

      # 構文
      when :LOOP # loop構文
        @broke = false
        #i = 0
        while true
          #p i
          #i += 1
          result = evaluate(tree[1], current_env, parent_object)
          if @broke
            #puts("breakされたので抜けました")
            @broke = false
            break
          end
          #puts "result: #{result}"
          return result if @returned
        end
        return @null_obj

      when :WHILE
        while true
          condition = evaluate(tree[1], current_env, parent_object)
          if (condition[0] == :INSTANCE && condition[1] == @boolean_class && condition[3] == false) ||
             (condition[0] == @null_obj)
            break
          end
          result = evaluate(tree[2], current_env, parent_object)
          if @broke
            @broke = false
            break
          end
          return result if @returned
        end
        return @null_obj
      when :IF
        tree[1].each do |if_stmt|
          if if_stmt
            condition = evaluate(if_stmt[0], current_env, parent_object)
            unless (condition[0] == :INSTANCE && condition[1] == @boolean_class && condition[3] == false) ||
                (condition[0] == @null_obj) # falseまたはnullでないときはtrue
              result = evaluate(if_stmt[1], current_env, parent_object)
              return result if @returned
              break
            end
          end
        end
        return result ? result : @null_obj
      when :FOR
        evaluate(tree[1], current_env, parent_object)


      when :INSTANCE
        return tree
      when :FUNCTION
        return tree
      when :CLASS
        return tree

      when :BREAK
        #puts "システムメッセージ：breakされました。"
        @broke = true
        return @null_obj
      when :RETURN
        result = evaluate(tree[1], current_env, parent_object)
        @returned = true
        result

      when :SELF
        raise "インスタンス関数ではありません" if parent_object.nil?
        return parent_object
      when :SUPER
        obj = parent_object.clone
        obj[1] = obj[1][1]
        return obj

      when :FUNC_CALL
        # 関数を取得
        function = evaluate(tree[1], current_env, parent_object)
        # インスタンスを取得
        new_parent_object = function[3] ? function[3] : parent_object
        if function && function[0] == :FUNCTION
          # 引数を取得
          #env = Marshal.load(Marshal.dump(current_env))
          env = current_env.clone()
          args = []
          tree[2].length.times do |i|
            args << evaluate(tree[2][i], env, parent_object)
          end
          env["_argv"] = [:INSTANCE, @list_class, nil, args]
          unless function[1].nil? #要求する引数がnilではない
            if function[1].length == args.length
              args.length.times do |i|
                env[function[1][i][1]] = [args[i], :PRIVATE, :DYNAMIC, :VARIABLE]
              end
            else
              raise "引数の数があっていません。必要な数:#{function[1].length}、現在の数:#{args.length}"
            end
          end
          # 関数を実行する
          result = evaluate(function[2], env, new_parent_object)
          @returned = false
          #puts "#{function.__id__} 関数呼び出し後の環境\n#{debug_env(env, 4)}"
          return result
        else
          raise("定義されていない関数、または関数でないオブジェクトが関数として呼び出されました")
        end

      # クラス定義
      when :CLASS_NEW
        class_env = {}
        evaluate(tree[2], class_env, nil)
        expands_cls = tree[1] ? evaluate(tree[1], current_env, parent_object): @object_class
        raise "Numberクラスから継承することはできません" if expands_cls == @number_class
        raise "Stringクラスから継承することはできません" if expands_cls == @string_class
        raise "Booleanクラスから継承することはできません" if expands_cls == @boolean_class
        cls = [:CLASS, expands_cls, class_env]
        return cls

      when :BUILD_IN
        env = current_env # 環境
        self_obj = parent_object  # self
        argv = current_env['_argv'][3] # 引数の配列
        return eval(tree[1])

    end
  end
  def debug_env(env, ind)
    code = "#{" " * ind}環境ID[#{env.__id__}]{\n"
    env.each_key do |k|
      code += "#{" " * (ind+4)}#{k}#{debug_obj(env[k][0], ind)}\n"
    end
    code += "#{" " * ind}}\n"
    return code
  end
  def debug_obj(obj, ind)
    if obj == @null_obj
      return "[NULLオブジェクト(#{obj.__id__})]"
    end
    case obj[0]
      when :CLASS
        if(obj == @object_class || obj == @number_class || obj == @string_class || obj == @list_class || obj == @hash_class)
          "クラス (#{obj.__id__} 親:#{obj[1].__id__})"
        else
          "クラス (#{obj.__id__} 親:#{obj[1].__id__})\n#{obj[2] ? debug_env(obj[2], ind+8) : '環境なし'}"
        end
      when :INSTANCE
        if obj[2]
          return "インスタンス (#{obj.__id__})\n#{debug_env(obj[2], ind+8)}#{obj[3] ? (", "+obj[3].to_s): ""}"
        else
          return "インスタンス (#{obj.__id__})#{obj[3] ? (", "+obj[3].to_s): ""}"
        end

      when :FUNCTION
        return "関数 (#{obj.__id__})"
    end
  end
  def run
    self.analysis
    return self.process
  end
end

if __FILE__ == $0
  # Radiusの動かし方

  # インスタンスを生成して
  radius = Radius.new

  # コードにテキストデータを代入
  File.open("program.rlb", "r") do |f|
    radius.code = f.read.chomp
  end
  p radius.code
  # 実行
  radius.run
end