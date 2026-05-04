
params.samplesheet = ""
params.conditions = ""
params.join_key = "sample"
params.outdir = ""
params.outname = "samplesheet.csv"
params.quotechar = '"'


process PUBLISH_CSV {
    publishDir params.outdir, pattern: "*.csv", mode: 'copy', saveAs: { params.outname }

    input:
    path csv

    output:
    path "*.csv"

    script:
    """
    cp ${csv} ${csv}_copy.csv
    """
}


workflow rnaseq2diffab {

    main:

    samplesCh = channel
        .fromPath( params.samplesheet )
        .splitCsv( header: true, quote: params.quotechar )

    conditionsCh = channel
        .fromPath( params.conditions )
        .splitCsv( header: true, quote: params.quotechar )

    mergedCh = samplesCh
        .combine( conditionsCh )
        .filter  { s, c -> s[ params.join_key ] == c[ params.join_key ] }
        .map     { s, c -> s + c }
        .collect()
        .flatMap { rows ->
            [ rows[0].keySet().join(',') ] + rows.collect { it.values().join(',') }
        }
        .collectFile( name: 'samplesheet.csv', newLine: true )

    emit:
    merged_samplesheet = mergedCh

}

workflow {
    main:
    rnaseq2diffab()
    PUBLISH_CSV(rnaseq2diffab.out.merged_samplesheet)
}
