MODULE Errors;
IMPORT F:=RawFiles,O:=Out,S:=Str,SYS:=SYSTEM;

CONST suffix='_errors'; maxLineLen=512;
VAR f:F.File; index,nofBytes:LONGINT; actChar:CHAR; 
    buf:ARRAY 4096 OF CHAR; 

TYPE tElem*    = POINTER TO tElemDesc;
     tElemDesc = RECORD
                  lin-,col-:LONGINT; 
                  msg-:POINTER TO ARRAY OF CHAR; 
                  prev,next-:tElem;
                 END;		  
VAR anchor-:tElem;		 

(************************************************************************************************************************)
PROCEDURE IsBefore(a,b:tElem):BOOLEAN; 
BEGIN (* IsBefore *)		       
 IF a.lin=b.lin THEN 
    RETURN a.col<b.col; 
 ELSE 
    RETURN a.lin<b.lin; 
 END; (* IF *)
END IsBefore;

(************************************************************************************************************************)
PROCEDURE Insert(e:tElem);
VAR p:tElem;
BEGIN (* Insert *)
 p:=anchor.prev; 
 WHILE IsBefore(e,p) DO
  p:=p.prev; 
 END; (* WHILE *)

 e.prev:=p; 
 e.next:=p.next; 
 p.next.prev:=e; 
 p.next:=e; 
END Insert;

(************************************************************************************************************************)
PROCEDURE RdNext;
BEGIN (* RdNext *)
 IF index>=nofBytes THEN 
    F.Read(f,SYS.ADR(buf),LEN(buf),nofBytes); 
    IF nofBytes=0 THEN actChar:=0X; RETURN; END; (* IF *)
    index:=0; 
 END; (* IF *)
 actChar:=buf[index]; INC(index); 
END RdNext;

(************************************************************************************************************************)
PROCEDURE RdNum(VAR val:LONGINT):BOOLEAN; 
VAR v:LONGINT; 
BEGIN (* RdNum *)	   
 LOOP
  CASE actChar OF
  |0X      : RETURN FALSE; 
  |'0'..'9': EXIT; 
  ELSE       RdNext;
  END; (* CASE *)
 END; (* LOOP *)
 
 v:=ORD(actChar)-48; 
 LOOP
  RdNext;
  CASE actChar OF
  |'0'..'9': v:=10*v+ORD(actChar)-48; 
  ELSE       EXIT; 
  END; (* CASE *)
 END; (* LOOP *)		    
 val:=v; 
 
 RETURN TRUE; 
END RdNum;

(************************************************************************************************************************)
PROCEDURE RdStr(VAR s:ARRAY OF CHAR):BOOLEAN; 
VAR dst:LONGINT; 
BEGIN (* RdStr *)			      
 WHILE actChar<=' ' DO RdNext; END; (* WHILE *)
 IF actChar=':' THEN RdNext; END; (* IF *)
 WHILE actChar<=' ' DO RdNext; END; (* WHILE *)

 dst:=0; 
 WHILE (actChar#0X) & (actChar#0AX) DO
  IF dst<LEN(s) THEN s[dst]:=actChar; INC(dst); END; (* IF *)
  RdNext;
 END; (* WHILE *)
 
 IF dst=LEN(s) THEN DEC(dst); END; (* IF *)
 s[dst]:=0X; 

 RETURN TRUE; 
END RdStr;

(************************************************************************************************************************)
PROCEDURE Read*(name:ARRAY OF CHAR):BOOLEAN; 
VAR len,line,column:LONGINT; fn:POINTER TO ARRAY OF CHAR; 
    str:ARRAY maxLineLen OF CHAR; e:tElem;
BEGIN (* Read *)
 NEW(anchor); anchor.prev:=anchor; anchor.next:=anchor; 
 anchor.lin:=MIN(LONGINT); anchor.col:=MIN(LONGINT); 
 
 len:=S.Length(name); 
 NEW(fn,len+S.Length(suffix)+1); 
 COPY(name,fn^); S.Append(fn^,suffix); 
 
 IF ~F.Accessible(fn^,FALSE) THEN RETURN FALSE; END; (* IF *)
 F.OpenInput(f,fn^); index:=0; nofBytes:=0; 
 
 RdNext;
 WHILE RdNum(line) & RdNum(column) & RdStr(str) DO 
  NEW(e); 
  e.lin:=line; e.col:=column;
  NEW(e.msg,S.Length(str)+1); 
  COPY(str,e.msg^); 
  Insert(e); 
 END; (* WHILE *)
 
 F.Close(f); 
 RETURN TRUE; 
END Read;

(************************************************************************************************************************)
END Errors.
