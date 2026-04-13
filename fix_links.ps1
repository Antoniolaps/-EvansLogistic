$files = Get-ChildItem -Path "c:\Users\gamme\ServicioTecnico\Propuesta1" -Recurse -Filter *.html

foreach ($f in $files) {
    if ($f.FullName -match "(?i)\\pages\\[^\\]+\\[^\\]+") {
        # Depth 2: pages/folder/file.html
        $prefix = "../../"
        $pagesPrefix = "../"
    } elseif ($f.FullName -match "(?i)\\pages\\[^\\]+") {
        # Depth 1: pages/file.html
        $prefix = "../"
        $pagesPrefix = ""
    } else {
        # Depth 0: index.html
        $prefix = ""
        $pagesPrefix = "pages/"
    }

    $content = Get-Content $f.FullName -Raw
    
    # Normalize pages links
    $content = $content -replace 'href="/pages/', 'href="[PAGES]'
    $content = $content -replace 'href="pages/', 'href="[PAGES]'
    $content = $content -replace 'href="\.\./pages/', 'href="[PAGES]'
    $content = $content -replace 'href="\.\./\.\./pages/', 'href="[PAGES]'
    
    # Normalize index links
    $content = $content -replace 'href="/index\.html"', 'href="[INDEX]"'
    $content = $content -replace 'href="\.\./index\.html"', 'href="[INDEX]"'
    $content = $content -replace 'href="\.\./\.\./index\.html"', 'href="[INDEX]"'
    $content = $content -replace 'href="index\.html"', 'href="[INDEX]"'
    
    # Standardize depth 1 files without pages/ prefix
    $content = $content -replace 'href="contacto\.html"', 'href="[PAGES]contacto.html"'
    $content = $content -replace 'href="proveedores\.html"', 'href="[PAGES]proveedores.html"'
    $content = $content -replace 'href="cotizacion\.html"', 'href="[PAGES]cotizacion.html"'
    $content = $content -replace 'href="terminos-condiciones\.html"', 'href="[PAGES]terminos-condiciones.html"'
    
    # Standardize depth 2 directory references
    $content = $content -replace 'href="nosotros/', 'href="[PAGES]nosotros/'
    $content = $content -replace 'href="servicios/', 'href="[PAGES]servicios/'
    $content = $content -replace 'href="noticias/', 'href="[PAGES]noticias/'
    
    $content = $content -replace 'href="\.\./nosotros/', 'href="[PAGES]nosotros/'
    $content = $content -replace 'href="\.\./servicios/', 'href="[PAGES]servicios/'
    $content = $content -replace 'href="\.\./noticias/', 'href="[PAGES]noticias/'

    $content = $content -replace 'href="\.\./\.\./nosotros/', 'href="[PAGES]nosotros/'
    $content = $content -replace 'href="\.\./\.\./servicios/', 'href="[PAGES]servicios/'
    $content = $content -replace 'href="\.\./\.\./noticias/', 'href="[PAGES]noticias/'

    # Finally replace with correct local prefix
    $content = $content -replace 'href="\[INDEX\]"', ("href=`"" + $prefix + "index.html`"")
    $content = $content -replace 'href="\[PAGES\]', ("href=`"" + $pagesPrefix)

    Set-Content -Path $f.FullName -Value $content
}
Write-Output "Links standardized successfully."
