# This value must be changed to match the number of public inputs (including return values!) in your program.
#bb write_vk -b ./target/skp.json -o ./target/vk
#bb prove -b ./target/skp.json -w ./target/witness-name.gz -o ./target/proof
#bb verify -k ./target/vk -p ./target/proof

NUM_PUBLIC_INPUTS=15
PUBLIC_INPUT_BYTES=480 #32 * NUM_PUBLIC_INPUTS
HEX_PUBLIC_INPUTS=$(head -c $PUBLIC_INPUT_BYTES ./target/proof | od -An -v -t x1 | tr -d $' \n')
HEX_PROOF=$(tail -c +$(($PUBLIC_INPUT_BYTES + 1)) ./target/proof | od -An -v -t x1 | tr -d $' \n')

echo "Public inputs:"
echo $HEX_PUBLIC_INPUTS

echo "Proof:"
echo "0x$HEX_PROOF"