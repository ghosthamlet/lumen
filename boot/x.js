function make_environment(){return([{}]);}macros=make_environment();symbol_macros=make_environment();function is_vararg(name){return((sub(name,(length(name)-3),length(name))=="..."));}function bind1(list,value){var forms=[];var i=0;var _2=list;while((i<length(_2))){var x=_2[i];if(is_list(x)){forms=join(forms,bind1(x,["at",value,i]));}else if(is_vararg(x)){var v=sub(x,0,(length(x)-3));push(forms,["local",v,["sub",value,i]]);break;}else{push(forms,["local",x,["at",value,i]]);}i=(i+1);}return(forms);}target="js";function length(x){return(x.length);}function is_empty(list){return((length(list)==0));}function sub(x,from,upto){if(is_string(x)){return(x.substring(from,upto));}else{return(x.slice(from,upto));}}function push(arr,x){return(arr.push(x));}function pop(arr){return(arr.pop());}function last(arr){return(arr[(length(arr)-1)]);}function join(a1,a2){return(a1.concat(a2));}function reduce(f,x){if(is_empty(x)){return(x);}else if((length(x)==1)){return(x[0]);}else{return(f(x[0],reduce(f,sub(x,1))));}}function filter(f,a){var a1=[];var _8=0;var _7=a;while((_8<length(_7))){var x=_7[_8];if(f(x)){push(a1,x);}_8=(_8+1);}return(a1);}function find(f,a){var _10=0;var _9=a;while((_10<length(_9))){var x=_9[_10];var x1=f(x);if(x1){return(x1);}_10=(_10+1);}}function map(f,a){var a1=[];var _12=0;var _11=a;while((_12<length(_11))){var x=_11[_12];push(a1,f(x));_12=(_12+1);}return(a1);}function collect(f,a){var a1=[];var _14=0;var _13=a;while((_14<length(_13))){var x=_13[_14];a1=join(a1,f(x));_14=(_14+1);}return(a1);}function getenv(env,k){var i=(length(env)-1);while((i>=0)){var v=env[i][k];if(v){return(v);}i=(i-1);}}function setenv(env,k,v){last(env)[k]=v;}function pushenv(env){return(push(env,{}));}function popenv(env){return(pop(env));}function char(str,n){return(str.charAt(n));}function search(str,pattern,start){var i=str.indexOf(pattern,start);if((i>=0)){return(i);}}function split(str,sep){return(str.split(sep));}fs=require("fs");function read_file(path){return(fs.readFileSync(path,"utf8"));}function write_file(path,data){return(fs.writeFileSync(path,data,"utf8"));}function print(x){return(console.log(x));}function write(x){return(process.stdout.write(x));}function exit(code){return(process.exit(code));}function is_string(x){return((type(x)=="string"));}function is_string_literal(x){return((is_string(x)&&(char(x,0)=="\"")));}function is_number(x){return((type(x)=="number"));}function is_boolean(x){return((type(x)=="boolean"));}function is_composite(x){return((type(x)=="object"));}function is_atom(x){return(!(is_composite(x)));}function is_table(x){return((is_composite(x)&&(x[0]==undefined)));}function is_list(x){return((is_composite(x)&&!((x[0]==undefined))));}function parse_number(str){var n=parseFloat(str);if(!(isNaN(n))){return(n);}}function to_string(x){if((x==undefined)){return("nil");}else if(is_boolean(x)){if(x){return("true");}else{return("false");}}else if(is_atom(x)){return((x+""));}else if(is_table(x)){return("#<table>");}else{var str="(";var i=0;var _16=x;while((i<length(_16))){var y=_16[i];str=(str+to_string(y));if((i<(length(x)-1))){str=(str+" ");}i=(i+1);}return((str+")"));}}function error(msg){throw(msg);return(undefined);}function type(x){return(typeof(x));}function apply(f,args){return(f.apply(f,args));}id_counter=0;function make_id(prefix){id_counter=(id_counter+1);return(("_"+(prefix||"")+id_counter));}eval_result=undefined;delimiters={"(":true,")":true,";":true,"\n":true};whitespace={" ":true,"\t":true,"\n":true};function make_stream(str){return({pos:0,string:str,len:length(str)});}function peek_char(s){if((s.pos<s.len)){return(char(s.string,s.pos));}}function read_char(s){var c=peek_char(s);if(c){s.pos=(s.pos+1);return(c);}}function skip_non_code(s){while(true){var c=peek_char(s);if(!(c)){break;}else if(whitespace[c]){read_char(s);}else if((c==";")){while((c&&!((c=="\n")))){c=read_char(s);}skip_non_code(s);}else{break;}}}read_table={};eof={};read_table[""]=function (s){var str="";while(true){var c=peek_char(s);if((c&&(!(whitespace[c])&&!(delimiters[c])))){str=(str+c);read_char(s);}else{break;}}var n=parse_number(str);if(!((n==undefined))){return(n);}else if((str=="true")){return(true);}else if((str=="false")){return(false);}else{return(str);}};read_table["("]=function (s){read_char(s);var l=[];while(true){skip_non_code(s);var c=peek_char(s);if((c&&!((c==")")))){push(l,read(s));}else if(c){read_char(s);break;}else{error(("Expected ) at "+s.pos));}}return(l);};read_table[")"]=function (s){return(error(("Unexpected ) at "+s.pos)));};read_table["\""]=function (s){read_char(s);var str="\"";while(true){var c=peek_char(s);if((c&&!((c=="\"")))){if((c=="\\")){str=(str+read_char(s));}str=(str+read_char(s));}else if(c){read_char(s);break;}else{error(("Expected \" at "+s.pos));}}return((str+"\""));};read_table["'"]=function (s){read_char(s);return(["quote",read(s)]);};read_table["`"]=function (s){read_char(s);return(["quasiquote",read(s)]);};read_table[","]=function (s){read_char(s);if((peek_char(s)=="@")){read_char(s);return(["unquote-splicing",read(s)]);}else{return(["unquote",read(s)]);}};function read(s){skip_non_code(s);var c=peek_char(s);if(c){return(((read_table[c]||read_table[""]))(s));}else{return(eof);}}function read_from_string(str){return(read(make_stream(str)));}operators={common:{"+":"+","-":"-","*":"*","/":"/","<":"<",">":">","=":"==","<=":"<=",">=":">="},js:{"and":"&&","or":"||","cat":"+"},lua:{"and":" and ","or":" or ","cat":".."}};function get_op(op){return((operators["common"][op]||operators[target][op]));}function is_operator(form){return((is_list(form)&&!((get_op(form[0])==undefined))));}function get_symbol_macro(form){return(getenv(symbol_macros,form));}function get_macro(form){return(getenv(macros,form));}function is_quoting(depth){return(is_number(depth));}function is_quasiquoting(depth){return((is_quoting(depth)&&(depth>0)));}function is_can_unquote(depth){return((is_quoting(depth)&&(depth==1)));}function macroexpand(form){if(get_symbol_macro(form)){return(macroexpand(get_symbol_macro(form)));}else if(is_atom(form)){return(form);}else{var name=form[0];if((name=="quote")){return(form);}else if((name=="defmacro")){return(form);}else if(get_macro(name)){return(macroexpand(apply(get_macro(name),sub(form,1))));}else if(((name=="lambda")||(name=="each"))){var _=form[0];var args=form[1];var body=sub(form,2);return(join([name,args],macroexpand(body)));}else if((name=="defun")){var _=form[0];var fn=form[1];var args=form[2];var body=sub(form,3);return(join(["defun",fn,args],macroexpand(body)));}else{return(map(macroexpand,form));}}}function quasiexpand(form,depth){if(is_quasiquoting(depth)){if(is_atom(form)){return(["quote",form]);}else if((is_can_unquote(depth)&&(form[0]=="unquote"))){return(quasiexpand(form[1]));}else if(((form[0]=="unquote")||(form[0]=="unquote-splicing"))){return(quasiquote_list(form,(depth-1)));}else if((form[0]=="quasiquote")){return(quasiquote_list(form,(depth+1)));}else{return(quasiquote_list(form,depth));}}else if(is_atom(form)){return(form);}else if((form[0]=="quote")){return(["quote",form[1]]);}else if((form[0]=="quasiquote")){return(quasiexpand(form[1],1));}else{return(map(function (x){return(quasiexpand(x,depth));},form));}}function quasiquote_list(form,depth){var xs=[["list"]];var _19=0;var _18=form;while((_19<length(_18))){var x=_18[_19];if((is_list(x)&&is_can_unquote(depth)&&(x[0]=="unquote-splicing"))){push(xs,quasiexpand(x[1]));push(xs,["list"]);}else{push(last(xs),quasiexpand(x,depth));}_19=(_19+1);}if((length(xs)==1)){return(xs[0]);}else{return(reduce(function (a,b){return(["join",a,b]);},filter(function (x){return(((length(x)==0)||!(((length(x)==1)&&(x[0]=="list")))));},xs)));}}function compile_args(forms,is_compile){var str="(";var i=0;var _20=forms;while((i<length(_20))){var x=_20[i];var x1=(function (){if(is_compile){return(compile(x));}else{return(identifier(x));}})();str=(str+x1);if((i<(length(forms)-1))){str=(str+",");}i=(i+1);}return((str+")"));}function compile_body(forms,is_tail){var str="";var i=0;var _21=forms;while((i<length(_21))){var x=_21[i];var is_t=(is_tail&&(i==(length(forms)-1)));str=(str+compile(x,true,is_t));i=(i+1);}return(str);}function identifier(id){var id2="";var i=0;while((i<length(id))){var c=char(id,i);if((c=="-")){c="_";}id2=(id2+c);i=(i+1);}var last=(length(id)-1);if((char(id,last)=="?")){var name=sub(id2,0,last);id2=("is_"+name);}return(id2);}function compile_atom(form){if((form=="nil")){if((target=="js")){return("undefined");}else{return("nil");}}else if((is_string(form)&&!(is_string_literal(form)))){return(identifier(form));}else{return(to_string(form));}}function compile_call(form){if((length(form)==0)){return((compiler("list"))(form));}else{var fn=form[0];var fn1=compile(fn);var args=compile_args(sub(form,1),true);if(is_list(fn)){return(("("+fn1+")"+args));}else if(is_string(fn)){return((fn1+args));}else{return(error("Invalid function call"));}}}function compile_operator(_23){var op=_23[0];var args=sub(_23,1);var str="(";var op1=get_op(op);var i=0;var _22=args;while((i<length(_22))){var arg=_22[i];if(((op1=="-")&&(length(args)==1))){str=(str+op1+compile(arg));}else{str=(str+compile(arg));if((i<(length(args)-1))){str=(str+op1);}}i=(i+1);}return((str+")"));}function compile_branch(condition,body,is_first,is_last,is_tail){var cond1=compile(condition);var body1=compile(body,true,is_tail);var tr=(function (){if((is_last&&(target=="lua"))){return(" end ");}else{return("");}})();if((is_first&&(target=="js"))){return(("if("+cond1+"){"+body1+"}"));}else if(is_first){return(("if "+cond1+" then "+body1+tr));}else if(((condition==undefined)&&(target=="js"))){return(("else{"+body1+"}"));}else if((condition==undefined)){return((" else "+body1+" end "));}else if((target=="js")){return(("else if("+cond1+"){"+body1+"}"));}else{return((" elseif "+cond1+" then "+body1+tr));}}function bind_arguments(args,body){var args1=[];var _25=0;var _24=args;while((_25<length(_24))){var arg=_24[_25];if(is_vararg(arg)){var v=sub(arg,0,(length(arg)-3));var expr=(function (){if((target=="js")){return(["Array.prototype.slice.call","arguments",length(args1)]);}else{push(args1,"...");return(["list","..."]);}})();body=join([["local",v,expr]],body);break;}else if(is_list(arg)){var v=make_id();push(args1,v);body=macroexpand(join([["bind",arg,v]],body));}else{push(args1,arg);}_25=(_25+1);}return([args1,body]);}function compile_function(args,body,name){name=(name||"");var expanded=bind_arguments(args,body);var args1=compile_args(expanded[0]);var body1=compile_body(expanded[1],true);if((target=="js")){return(("function "+name+args1+"{"+body1+"}"));}else{return(("function "+name+args1+body1+" end "));}}function quote_form(form){if(is_atom(form)){if(is_string_literal(form)){var str=sub(form,1,(length(form)-1));return(("\"\\\""+str+"\\\"\""));}else if(is_string(form)){return(("\""+form+"\""));}else{return(to_string(form));}}else{return((compiler("list"))(form,0));}}function compile_special(form,is_stmt,is_tail){var name=form[0];if((!(is_stmt)&&is_statement(name))){return(compile([["lambda",[],form]],false,is_tail));}else{var is_tr=(is_stmt&&!(is_self_terminating(name)));var tr=(function (){if(is_tr){return(";");}else{return("");}})();return(((compiler(name))(sub(form,1),is_tail)+tr));}}special={};function is_special(form){return((is_list(form)&&!((special[form[0]]==undefined))));}function compiler(name){return(special[name]["compiler"]);}function is_statement(name){return(special[name]["statement"]);}function is_self_terminating(name){return(special[name]["terminated"]);}special["do"]={compiler:function (forms,is_tail){return(compile_body(forms,is_tail));},statement:true,terminated:true};special["if"]={compiler:function (form,is_tail){var str="";var i=0;var _27=form;while((i<length(_27))){var condition=_27[i];var is_last=(i>=(length(form)-2));var is_else=(i==(length(form)-1));var is_first=(i==0);var body=form[(i+1)];if(is_else){body=condition;condition=undefined;}i=(i+1);str=(str+compile_branch(condition,body,is_first,is_last,is_tail));i=(i+1);}return(str);},statement:true,terminated:true};special["while"]={compiler:function (form){var condition=compile(form[0]);var body=compile_body(sub(form,1));if((target=="js")){return(("while("+condition+"){"+body+"}"));}else{return(("while "+condition+" do "+body+" end "));}},statement:true,terminated:true};special["defun"]={compiler:function (_28){var name=_28[0];var args=_28[1];var body=sub(_28,2);var id=identifier(name);return(compile_function(args,body,id));},statement:true,terminated:true};special["defmacro"]={compiler:function (_29){var name=_29[0];var args=_29[1];var body=sub(_29,2);var lambda=join(["lambda",args],body);var register=["setenv","macros",["quote",name],lambda];eval(compile_for_target("js",register,true));return("");},statement:true,terminated:true};special["return"]={compiler:function (form){return(compile_call(join(["return"],form)));},statement:true};special["local"]={compiler:function (_30){var name=_30[0];var value=_30[1];var id=identifier(name);var keyword=(function (){if((target=="js")){return("var ");}else{return("local ");}})();if((value==undefined)){return((keyword+id));}else{var v=compile(value);return((keyword+id+"="+v));}},statement:true};special["each"]={compiler:function (_31){var t=_31[0][0];var k=_31[0][1];var v=_31[0][2];var body=sub(_31,1);var t1=compile(t);if((target=="lua")){var body1=compile_body(body);return(("for "+k+","+v+" in pairs("+t1+") do "+body1+" end"));}else{var body1=compile_body(join([["set",v,["get",t,k]]],body));return(("for("+k+" in "+t1+"){"+body1+"}"));}},statement:true};special["set"]={compiler:function (form){if((length(form)<2)){error("Missing right-hand side in assignment");}var lh=compile(form[0]);var rh=compile(form[1]);return((lh+"="+rh));},statement:true};special["get"]={compiler:function (_32){var object=_32[0];var key=_32[1];var o=compile(object);var k=compile(key);if(((target=="lua")&&(char(o,0)=="{"))){o=("("+o+")");}return((o+"["+k+"]"));}};special["dot"]={compiler:function (_33){var object=_33[0];var key=_33[1];var o=compile(object);var id=identifier(key);return((o+"."+id));}};special["not"]={compiler:function (_34){var expr=_34[0];var e=compile(expr);var open=(function (){if((target=="js")){return("!(");}else{return("(not ");}})();return((open+e+")"));}};special["list"]={compiler:function (forms,depth){var open=(function (){if((target=="lua")){return("{");}else{return("[");}})();var close=(function (){if((target=="lua")){return("}");}else{return("]");}})();var str="";var i=0;var _35=forms;while((i<length(_35))){var x=_35[i];var x1=(function (){if(is_quoting(depth)){return(quote_form(x));}else{return(compile(x));}})();str=(str+x1);if((i<(length(forms)-1))){str=(str+",");}i=(i+1);}return((open+str+close));}};special["table"]={compiler:function (forms){var sep=(function (){if((target=="lua")){return("=");}else{return(":");}})();var str="{";var i=0;while((i<(length(forms)-1))){var k=forms[i];if(!(is_string(k))){error(("Illegal table key: "+to_string(k)));}var v=compile(forms[(i+1)]);if(((target=="lua")&&is_string_literal(k))){k=("["+k+"]");}str=(str+k+sep+v);if((i<(length(forms)-2))){str=(str+",");}i=(i+2);}return((str+"}"));}};special["lambda"]={compiler:function (_36){var args=_36[0];var body=sub(_36,1);return(compile_function(args,body));}};special["quote"]={compiler:function (_37){var form=_37[0];return(quote_form(form));}};function is_can_return(form){if(is_special(form)){return(!(is_statement(form[0])));}else{return(true);}}function compile(form,is_stmt,is_tail){var tr=(function (){if(is_stmt){return(";");}else{return("");}})();if((is_tail&&is_can_return(form))){form=["return",form];}if((form==undefined)){return("");}else if(is_atom(form)){return((compile_atom(form)+tr));}else if(is_operator(form)){return((compile_operator(form)+tr));}else if(is_special(form)){return(compile_special(form,is_stmt,is_tail));}else{return((compile_call(form)+tr));}}function compile_file(file){var form;var output="";var s=make_stream(read_file(file));while(true){form=read(s);if((form==eof)){break;}output=(output+compile(macroexpand(form),true));}return(output);}function compile_files(files){var output="";var _39=0;var _38=files;while((_39<length(_38))){var file=_38[_39];output=(output+compile_file(file));_39=(_39+1);}return(output);}function compile_for_target(target1,form,is_stmt){var previous=target;target=target1;var result=compile(macroexpand(form),is_stmt);target=previous;return(result);}function rep(str){return(print(to_string(eval(compile(read_from_string(str))))));}function repl(){var execute=function (str){rep(str);return(write("> "));};write("> ");process.stdin.resume();process.stdin.setEncoding("utf8");return(process.stdin.on("data",execute));}args=sub(process.argv,2);standard=["boot.x","lib.x","reader.x","compiler.x"];function usage(){print("usage: x [<inputs>] [-o <output>] [-t <target>] [-e <expr>]");return(exit());}dir=args[0];if(((args[1]=="-h")||(args[1]=="--help"))){usage();}var inputs=[];var output=undefined;var target1=undefined;var expr=undefined;var i=1;var _40=args;while((i<length(_40))){var arg=_40[i];if(((arg=="-o")||(arg=="-t")||(arg=="-e"))){if((i==(length(args)-1))){print("missing argument for",arg);}else{i=(i+1);var arg2=args[i];if((arg=="-o")){output=arg2;}else if((arg=="-t")){target1=arg2;}else if((arg=="-e")){expr=arg2;}}}else if(("-"==sub(arg,0,1))){print("unrecognized option:",arg);usage();}else{push(inputs,arg);}i=(i+1);}if(output){if(target1){target=target1;}write_file(output,compile_files(inputs));}else{var _42=0;var _41=standard;while((_42<length(_41))){var file=_41[_42];eval(compile_file((dir+"/"+file)));_42=(_42+1);}var _44=0;var _43=inputs;while((_44<length(_43))){var file=_43[_44];eval(compile_file(file));_44=(_44+1);}if(expr){rep(expr);}else{repl();}}