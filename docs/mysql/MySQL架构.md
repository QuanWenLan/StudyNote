##### MySQL中update按条件更新  

```mysql
update salary set sex=case when sex="f" then "m" else "f" end;
update salary set sex = if(sex = 'f', 'm', 'f');
```



