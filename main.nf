
params.samplesheet = ""
params.conditions = ""
params.join_key = "sample"
params.outdir = ""
params.outname = "samplesheet.csv"
params.quotechar = '"'


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
        .map { rows ->
            rows[0].keySet().join(',') + '\n' +
            rows.collect { it.values().join(',') }.join('\n') + '\n'
        }
        .collectFile( name: params.outname, storeDir: params.outdir )

    emit:
    merged_samplesheet = mergedCh

}

workflow {
    main:
    rnaseq2diffab()
}
