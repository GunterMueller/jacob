MODULE TBL;

IMPORT
   Idents, OB, Storage;

TYPE
   tElem     = POINTER TO tElemDesc;
   tElemDesc = RECORD
                tab         : OB.tOB;
                serverIdent : Idents.tIdent;
                next        : tElem;
               END;
VAR
   head      : tElem;

(*------------------------------------------------------------------------------------------------------------------------------*)
PROCEDURE Retrieve*(VAR tab : OB.tOB; serverIdent : Idents.tIdent) : BOOLEAN;
VAR
   e : tElem;
BEGIN (* Retrieve *)
 e:=head;
 WHILE e#NIL DO
  IF e^.serverIdent=serverIdent THEN tab:=e^.tab; RETURN TRUE; END;
  e:=e^.next;
 END; (* WHILE *)
 RETURN FALSE;
END Retrieve;

(*------------------------------------------------------------------------------------------------------------------------------*)
PROCEDURE Store*(tab : OB.tOB; serverIdent : Idents.tIdent);
VAR
   e : tElem;
BEGIN (* Store *)
 NEW(e);
 e^.tab         := tab;
 e^.serverIdent := serverIdent;
 e^.next        := head;
 head           := e;
END Store;

(*------------------------------------------------------------------------------------------------------------------------------*)
BEGIN (* TBL *)
 head:=NIL;
END TBL.


