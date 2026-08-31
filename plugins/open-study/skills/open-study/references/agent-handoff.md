# Handing material to another agent or workflow

Read this when the caller is a workflow or another agent rather than a person
reading prose.

When the caller is a workflow or another agent rather than a person reading prose, call `open-study:study_brief` once per video instead of five paginated reads. It returns identity, the stored analysis, the transcript up to `transcript_limit` (400 by default, 1000 at most), comments, and a Mermaid mind map, and names any part it could not read in `unavailable`. Return that structure rather than narrating it, keep `bvid` on every claim, and keep the provenance labels intact — a downstream agent cannot tell a transcript claim from a comment opinion or a generated analysis unless you say which is which.

The mind map is built only from stored analysis fields. Present it as exactly that, and do not add branches the analysis does not contain.

