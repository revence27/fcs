old_pieceName = (nom, nom1, chap, chap1, ver1, nom2, chap2, ver2) ->
  them1 = ver1.split(' ')
  them2 = ver2.split(' ')
  ver1  = them1[0]
  ver2  = them2[them2.length - 1]
  if (nom != '' and nom != nom1) or (chap != chap1)
    unless ver1 == '1' and chap1 == '1'
      nom1  = nom
      chap1 = chap unless ver1 == '1'
  ans = "#{nom1} #{chap1}#{(if nom1 == nom2 then (if chap1 == chap2 then '' else '-' + chap2) else ('-' + nom2 + ' ' + chap2))}"
  ans

pieceName = (nom, nom1, chap, chap1, ver1, nom2, chap2, ver2) ->
  them1 = ver1.split(' ')
  them2 = ver2.split(' ')
  ver1  = them1[0]
  ver2  = them2[them2.length - 1]
  if (nom != '' and nom != nom1) or (chap != chap1)
    unless ver1 == '1' and chap1 == '1'
      nom1  = nom
      chap1 = chap unless ver1 == '1'
  ans = "#{nom1} #{chap1}:#{ver1}#{(if nom1 == nom2 then (if chap1 == chap2 then (if ver1 == ver2 then '' else '-' + ver2) else '-' + chap2 + ':' + ver2) else ('-' + nom2 + ' ' + chap2 + ':' + ver2))}"
  ans

leading = (n1, c1, ln) ->
  if n1 == '' or c1 == ''
    ln
  else
    if (ln != n1) and ln != ''
      ''
    else
      "#{n1} #{c1}"

tailing = (n1, c1, ln) ->
  if n1 == '' or c1 == ''
    ln
  else
    if (ln != n1) and ln != ''
      ''
    else
      "#{n1} #{c1}"

sofar = 0
upper = 0
pass  = 1
prev  = 0
displayPage = (cpt) ->
  dig = parseInt(cpt)
  if dig < sofar
    pass  = 2
    console.log('Second pass ...')
    upper = parseFloat((sofar).toFixed(2))
  sofar = dig
  if pass > 1
    pc  = (parseFloat((dig).toFixed(2)) / upper) * 100.00
    console.log("#{pc.toFixed(1)}%") unless prev == dig
  else
    console.log('First pass ...') if sofar == 1
    # console.log(dig)
  prev  = dig

Prince.addScriptFunc 'leading', leading
Prince.addScriptFunc 'tailing', tailing
Prince.addScriptFunc 'displayPage', displayPage
